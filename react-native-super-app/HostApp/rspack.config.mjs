import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as Repack from '@callstack/repack';
import { withZephyr } from 'zephyr-repack-plugin';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const USE_ZEPHYR = Boolean(process.env.ZC);

/**
 * Rspack configuration enhanced with Re.Pack defaults for React Native.
 *
 * Learn about Rspack configuration: https://rspack.dev/config/
 * Learn about Re.Pack configuration: https://re-pack.dev/docs/guides/configuration
 */
const config = (env) => {
  const { platform, mode } = env;
  
  return {
    context: __dirname,
    entry: './index.js',
    resolve: {
      // 1. Understand the file path of ios and android file extensions
      // 2. Configure the output to be as close to Metro as possible
      ...Repack.getResolveOptions(),
    },
    output: {
      // Unique name for module federation HMR and runtime
      uniqueName: 'react-native-host-app',
    },
    module: {
      rules: [
        ...Repack.getJsTransformRules(),
        ...Repack.getAssetTransformRules(),
      ],
    },
    plugins: [
      new Repack.RepackPlugin({
        platform,
      }),
      new Repack.plugins.ModuleFederationPluginV2({
        name: 'HostApp',
        filename: 'HostApp.container.js.bundle',
        dts: false,
        remotes: {
          // MiniApp remotes - will be loaded from localhost in dev, Zephyr in production
          UserProfileApp: `UserProfileApp@http://localhost:9001/${platform}/UserProfileApp.container.js.bundle`,
          ShoppingCartApp: `ShoppingCartApp@http://localhost:9002/${platform}/ShoppingCartApp.container.js.bundle`,
          SettingsApp: `SettingsApp@http://localhost:9003/${platform}/SettingsApp.container.js.bundle`,
        },
        shared: {
          react: {
            singleton: true,
            version: '18.3.1',
            eager: true,
          },
          'react-native': {
            singleton: true,
            version: '0.75.4',
            eager: true,
          },
          '@react-navigation/native': {
            singleton: true,
            eager: true,
          },
          '@react-navigation/native-stack': {
            singleton: true,
            eager: true,
          },
          '@react-navigation/bottom-tabs': {
            singleton: true,
            eager: true,
          },
          'react-native-safe-area-context': {
            singleton: true,
            eager: true,
          },
          'react-native-screens': {
            singleton: true,
            eager: true,
          },
          'react-native-vector-icons': {
            singleton: true,
            eager: true,
          },
        },
      }),
      // Supports for new architecture - Hermes bytecode optimization
      new Repack.plugins.HermesBytecodePlugin({
        enabled: mode === 'production',
        test: /\.(js)?bundle$/,
        exclude: /index.bundle$/,
      }),
    ],
  };
};

export default USE_ZEPHYR ? withZephyr()(config) : config;