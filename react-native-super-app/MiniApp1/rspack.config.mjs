import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as Repack from '@callstack/repack';
import { withZephyr } from 'zephyr-repack-plugin';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const USE_ZEPHYR = Boolean(process.env.ZC);
const STANDALONE = Boolean(process.env.STANDALONE);

/**
 * Rspack configuration enhanced with Re.Pack defaults for React Native.
 *
 * Learn about Rspack configuration: https://rspack.dev/config/
 * Learn about Re.Pack configuration: https://re-pack.dev/docs/guides/configuration
 */
const config = (env) => {
  const { platform, mode } = env;
  
  return {
    mode,
    context: __dirname,
    entry: './index.js',
    resolve: {
      ...Repack.getResolveOptions(),
    },
    output: {
      uniqueName: 'react-native-user-profile-app',
    },
    module: {
      rules: [
        ...Repack.getJsTransformRules(),
        ...Repack.getAssetTransformRules({ inline: true }),
      ],
    },
    plugins: [
      new Repack.RepackPlugin({
        platform,
      }),
      new Repack.plugins.ModuleFederationPluginV2({
        name: 'UserProfileApp',
        filename: 'UserProfileApp.container.js.bundle',
        dts: false,
        exposes: {
          './App': './src/App.tsx',
        },
        shared: {
          react: {
            singleton: true,
            version: '18.3.1',
            eager: STANDALONE,
          },
          'react-native': {
            singleton: true,
            version: '0.75.4',
            eager: STANDALONE,
          },
          'react-native-safe-area-context': {
            singleton: true,
            eager: STANDALONE,
          },
          'react-native-vector-icons': {
            singleton: true,
            eager: STANDALONE,
          },
        },
      }),
      new Repack.plugins.HermesBytecodePlugin({
        enabled: mode === 'production',
        test: /\.(js)?bundle$/,
        exclude: /index.bundle$/,
      }),
    ],
  };
};

export default USE_ZEPHYR ? withZephyr()(config) : config;