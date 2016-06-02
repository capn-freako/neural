module MyPrelude
    ( NFData(..)
    , (&), (^.), (.~), Lens', Getter, to, lens
    , when, unless, forM, forM_, void, replicateM
    , Identity(..)
    , MonadIO(..)
    , MonadRandom, getRandom, getRandomR, RandT, runRandT, evalRandT, StdGen, mkStdGen
    , MonadState(..)
    , lift
    , State, StateT, modify, runState, evalState, execState, runStateT, evalStateT, execStateT
    , Writer, WriterT, tell, runWriter, execWriter, runWriterT, execWriterT
    , lefts, rights
    , toList
    , on
    , sort, sortBy, minimumBy, maximumBy, foldl', intercalate
    , catMaybes, fromJust
    , (<>)
    , getDirectoryContents
    , getArgs
    , (</>), (<.>)
    , withFile, IOMode(..), hPutStr, hPutStrLn
    , printf
    ) where

import Control.DeepSeq            (NFData(..))
import Control.Lens               ((&), (^.), (.~), Lens', Getter, to, lens)
import Control.Monad              (when, unless, forM, forM_, void, replicateM)
import Control.Monad.Identity     (Identity(..))
import Control.Monad.IO.Class     (MonadIO(..))
import Control.Monad.Random       (MonadRandom, getRandom, getRandomR, RandT, runRandT, evalRandT, StdGen, mkStdGen)
import Control.Monad.State.Class  (MonadState(..))
import Control.Monad.Trans.Class  (lift)
import Control.Monad.Trans.State  (State, StateT, modify, runState, evalState, execState, runStateT, evalStateT, execStateT)
import Control.Monad.Trans.Writer (Writer, WriterT, tell, runWriter, execWriter, runWriterT, execWriterT)
import Data.Either                (lefts, rights)
import Data.Foldable              (toList)
import Data.Function              (on)
import Data.List                  (sort, sortBy, minimumBy, maximumBy, foldl', intercalate)
import Data.Maybe                 (catMaybes, fromJust)
import Data.Monoid                ((<>))
import System.Directory           (getDirectoryContents)
import System.Environment         (getArgs)
import System.FilePath            ((</>), (<.>))
import System.IO                  (withFile, IOMode(..), hPutStr, hPutStrLn)
import Text.Printf                (printf)