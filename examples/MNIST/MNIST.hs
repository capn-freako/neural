{-# LANGUAGE DataKinds #-}

module Main where

import           Codec.Picture
import           Control.Arrow
import qualified Data.Array     as A
import           Data.MyPrelude
import           Data.Utils
import           Numeric.Neural
import           Pipes.GZip     (decompress)
import qualified Pipes.Prelude  as P

main :: IO ()
main = do
    xs <- runSafeT $ P.toListM (trainSamples >-> P.take 1000)
    printf "loaded %d train samples\n" (length xs)
    ys <- runSafeT $ P.toListM (testSamples >-> P.take 500)
    printf "loaded %d test samples\n" (length ys)
    flip evalRandT (mkStdGen 999999) $ do
        xs' <- takeR 100 $ fst <$> xs
        m <- modelR (whiten mnistModel xs')
        runEffect $
                simpleBatchP xs 20
            >-> descentP m 1 (const 0.1)
            >-> reportTSP 1 report
            >-> consumeTSP (check ys)

  where

    report ts = liftIO $ printf "%7d %8.6f %10.8f\n" (tsGeneration ts) (tsEta ts) (tsBatchError ts)

    check ys ts = --return $ if tsGeneration ts == 3 then Just () else Nothing
        if tsGeneration ts `mod` 5 == 0
            then do
                let a = accuracy (tsModel ts) ys :: Double
                liftIO $ printf "\naccuracy %f\n\n" a
                return Nothing
            else return Nothing

    correct m (img, d) = model m img == d

    accuracy m ys = let c = length $ filter (correct m) ys
                    in  fromIntegral c / fromIntegral (length ys)

type Img = Image Pixel8

data Digit = Zero | One | Two | Three | Four | Five | Six | Seven | Eight | Nine
    deriving (Show, Read, Eq, Ord, Enum, Bounded)

type Sample = (Img, Digit)

trainImagesFile, trainLabelsFile, testImagesFile, testLabelsFile :: FilePath
trainImagesFile = "examples" </> "MNIST" </> "train-images-idx3-ubyte" <.> "gz"
trainLabelsFile = "examples" </> "MNIST" </> "train-labels-idx1-ubyte" <.> "gz"
testImagesFile  = "examples" </> "MNIST" </> "t10k-images-idx3-ubyte"  <.> "gz"
testLabelsFile  = "examples" </> "MNIST" </> "t10k-labels-idx1-ubyte"  <.> "gz"

bytes :: (MonadSafe m, MonadIO m) => FilePath -> Producer Word8 m ()
bytes f = decompress (fromFile f) >-> toWord8

labels :: (MonadSafe m, MonadIO m) => FilePath -> Producer Digit m ()
labels f = bytes f >-> P.drop 8 >-> P.map (toEnum . fromIntegral)

images :: (MonadSafe m, MonadIO m) => FilePath -> Producer Img m ()
images f = bytes f >-> P.drop 16 >-> chunks (28 * 28) >-> P.map g

  where

    g xs = let a = A.listArray ((0, 0), (27, 27)) xs
           in  generateImage (\x y -> 255 - a A.! (y, x)) 28 28

trainSamples, testSamples :: (MonadSafe m, MonadIO m) => Producer Sample m ()
trainSamples = P.zip (images trainImagesFile) (labels trainLabelsFile)
testSamples  = P.zip (images testImagesFile)  (labels testLabelsFile)

writeImg :: MonadIO m => FilePath -> Img -> m ()
writeImg f i = liftIO $ saveTiffImage (f <.> "tiff") (ImageY8 i)

mnistModel :: Classifier (Matrix 28 28) 10 Img Digit
mnistModel = mkStdClassifier c i where

    c = f ^>> (tanhLayer :: Layer 784 10) >>> tanhLayer

    i img = let m = mgenerate $ \(x, y) -> fromIntegral (pixelAt img x y) in force m

    f :: Matrix 28 28 Analytic -> Vector 784 Analytic
    f m = generate $ \w -> m !!! (w `mod` 28, w `div` 28)