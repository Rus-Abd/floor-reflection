import { defineConfig } from 'vite';
import glslify from 'rollup-plugin-glslify';
import * as path from 'path';

export default defineConfig({
  root: '',
  base: './', // for Github pages, otherwise use './'
  build: {
    outDir: './dist',
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './'),
    },
  },
  plugins: [glslify()],
});
