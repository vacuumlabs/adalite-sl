-- | Wallet unit tests

module Main (main) where

import           Universum

import           Test.Hspec (Spec, describe, hspec, parallel)

import           InputSelection.Evaluation (evalUsingGenData, evalUsingReplay)
import           InputSelection.Evaluation.Options (Command (..), evalCommand,
                     getEvalOptions)
import           InputSelection.Evaluation.Replot (replot)
import           Test.Pos.Util.Parallel.Parallelize (parallelizeAllCores)

import qualified DeltaCompressionSpecs
import qualified Test.Spec.Accounts
import qualified Test.Spec.Addresses
import qualified Test.Spec.CoinSelection
import qualified Test.Spec.GetTransactions
import qualified Test.Spec.Kernel
import qualified Test.Spec.Keystore
import qualified Test.Spec.Models
import qualified Test.Spec.NewPayment
import qualified Test.Spec.Submission
import qualified Test.Spec.Translation
import qualified Test.Spec.Wallets
import qualified Test.Spec.WalletWorker
import           TxMetaStorageSpecs (txMetaStorageSpecs)

{-------------------------------------------------------------------------------
  Main test driver
-------------------------------------------------------------------------------}

main :: IO ()
main = do
    parallelizeAllCores
    mEvalOptions <- getEvalOptions
    case mEvalOptions of
      Nothing -> do
        -- _showContext
        hspec $ tests
      Just evalOptions ->
        -- NOTE: The coin selection must be invoked with @eval@
        -- Run @wallet-unit-tests eval --help@ for details.
        case evalCommand evalOptions of
          RunSimulation simOpts ->
            evalUsingGenData evalOptions simOpts
          Replay replayOpts ->
            evalUsingReplay evalOptions replayOpts
          Replot replotOpts ->
            replot evalOptions replotOpts

-- | Debugging: show the translation context
-- _showContext :: IO ()
-- _showContext = do
--     putStrLn $ runTranslateNoErrors $ withConfig $
--       sformat build <$> ask
--     putStrLn $ runTranslateNoErrors $
--       let bootstrapTransaction' :: TransCtxt -> Transaction GivenHash Addr
--           bootstrapTransaction' = bootstrapTransaction
--       in sformat build . bootstrapTransaction' <$> ask

{-------------------------------------------------------------------------------
  Tests proper
-------------------------------------------------------------------------------}

tests :: Spec
tests = parallel $ describe "Wallet unit tests" $ do
    Test.Spec.Addresses.spec
    DeltaCompressionSpecs.spec
    Test.Spec.Kernel.spec
    Test.Spec.GetTransactions.spec
    Test.Spec.Translation.spec
    Test.Spec.Models.spec
    Test.Spec.WalletWorker.spec
    Test.Spec.Submission.spec
    txMetaStorageSpecs
    Test.Spec.CoinSelection.spec
    Test.Spec.Keystore.spec
    Test.Spec.Wallets.spec
    Test.Spec.NewPayment.spec
    Test.Spec.Accounts.spec
