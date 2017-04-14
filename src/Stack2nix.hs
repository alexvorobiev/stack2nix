{-# LANGUAGE OverloadedStrings #-}

module Stack2nix (test) where

import Data.Maybe (fromMaybe)
import Data.Text (Text, unpack)
import qualified Data.Yaml as Y
import Data.Yaml (FromJSON(..), (.:), (.:?), (.!=))

data Config =
  Config { resolver  :: Text
         , packages  :: [Package]
         , extraDeps :: [Text]
         }
  deriving (Show)

data Package = LocalPkg FilePath
             | RemotePkg RemotePkgConf
             deriving (Show)

data RemotePkgConf =
  RemotePkgConf { gitUrl :: Text
                , commit :: Text
                , extraDep :: Bool
                }
  deriving (Show)

instance FromJSON Config where
  parseJSON (Y.Object v) =
    Config <$>
    v .: "resolver" <*>
    v .: "packages" <*>
    v .: "extra-deps"
  parseJSON _ = fail "Expected Object for Config value"

instance FromJSON Package where
  parseJSON (Y.String v) = return $ LocalPkg $ unpack v
  parseJSON obj@(Y.Object _) = RemotePkg <$> parseJSON obj
  parseJSON _ = fail "Expected String or Object for Package value"

instance FromJSON RemotePkgConf where
  parseJSON (Y.Object v) = do
    loc <- v .: "location"
    git <- loc .: "git"
    commit <- loc .: "commit"
    extra <- v .:? "extra-dep" .!= False
    return $ RemotePkgConf git commit extra
  parseJSON _ = fail "Expected Object for RemotePkgConf value"

test :: IO ()
test = do
  conf <- Y.decodeFile sampleFile :: IO (Maybe Config)
  putStrLn $ fromMaybe "..." (show <$> conf)
  where
    sampleFile = "test.yaml"