import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';
import { OBJLoader } from 'three/examples/jsm/loaders/OBJLoader.js';
import { DRACOLoader } from 'three/examples/jsm/loaders/DRACOLoader.js';
import { FontLoader } from 'three/examples/jsm/loaders/FontLoader.js';
import { TextureLoader, AudioLoader } from 'three';

class LoaderManager {
  #assets;
  #textureLoader = new TextureLoader();
  #GLTFLoader = new GLTFLoader();
  #OBJLoader = new OBJLoader();
  #DRACOLoader = new DRACOLoader();
  #FontLoader = new FontLoader();
  #AudioLoader = new AudioLoader();

  constructor() {
    this.#assets = {}; // Dictionary of assets, can be different type, gltf, texture, img, font, feel free to make a Enum if using TypeScript
  }

  get assets() {
    return this.#assets;
  }

  set assets(value) {
    this.#assets = value;
  }

  /**
   * Public method
   */

  get(name) {
    return this.#assets[name];
  }

  load = (data, onProgressCallback) =>
    new Promise((resolve) => {
      const promises = [];
      let loadedCount = 0;
      const totalAssets = data.length;

      const onAssetLoaded = () => {
        loadedCount++;
        const percentageLoaded = (loadedCount / totalAssets) * 100;
        if (onProgressCallback) {
          onProgressCallback(percentageLoaded);
        }

        if (loadedCount === totalAssets) {
          resolve();
        }
      };

      for (let i = 0; i < data.length; i++) {
        const { name, gltf, texture, img, font, obj, audio } = data[i];

        if (!this.#assets[name]) {
          this.#assets[name] = {};
        }

        if (gltf) {
          promises.push(this.loadGLTF(gltf, name, onAssetLoaded));
        }

        if (texture) {
          promises.push(this.loadTexture(texture, name, onAssetLoaded));
        }

        if (img) {
          promises.push(this.loadImage(img, name, onAssetLoaded));
        }

        if (font) {
          promises.push(this.loadFont(font, name, onAssetLoaded));
        }

        if (obj) {
          promises.push(this.loadObj(obj, name, onAssetLoaded));
        }
        if (audio) {
          promises.push(this.loadAudio(audio, name, onAssetLoaded));
        }
      }

      Promise.all(promises).then(() => resolve());
    });

  loadGLTF(url, name, onAssetLoaded) {
    return new Promise((resolve) => {
      this.#DRACOLoader.setDecoderPath(
        'https://www.gstatic.com/draco/v1/decoders/'
      );
      this.#GLTFLoader.setDRACOLoader(this.#DRACOLoader);

      this.#GLTFLoader.load(
        url,
        (result) => {
          this.#assets[name].gltf = result;
          onAssetLoaded();
          resolve(result);
        },
        undefined,
        (e) => {
          console.log(e);
        }
      );
    });
  }

  loadTexture(url, name, onAssetLoaded) {
    if (!this.#assets[name]) {
      this.#assets[name] = {};
    }
    return new Promise((resolve) => {
      this.#textureLoader.load(url, (result) => {
        this.#assets[name].texture = result;
        onAssetLoaded();
        resolve(result);
      });
    });
  }

  loadImage(url, name, onAssetLoaded) {
    return new Promise((resolve) => {
      const image = new Image();

      image.onload = () => {
        this.#assets[name].img = image;
        onAssetLoaded();
        resolve(image);
      };

      image.src = url;
    });
  }

  loadFont(url, name, onAssetLoaded) {
    // you can convert font to typeface.json using https://gero3.github.io/facetype.js/
    return new Promise((resolve) => {
      this.#FontLoader.load(
        url,

        // onLoad callback
        (font) => {
          this.#assets[name].font = font;
          onAssetLoaded();
          resolve(font);
        },

        // onProgress callback
        () =>
          // xhr
          {
            // console.log((xhr.loaded / xhr.total) * 100 + '% loaded')
          },

        // onError callback
        (err) => {
          console.log('An error happened', err);
        }
      );
    });
  }

  // https://threejs.org/docs/#examples/en/loaders/OBJLoader
  loadObj(url, name, onAssetLoaded) {
    return new Promise((resolve) => {
      // load a resource
      this.#OBJLoader.load(
        // resource URL
        url,
        // called when resource is loaded
        (object) => {
          this.#assets[name].obj = object;
          onAssetLoaded();
          resolve(object);
        },
        // onProgress callback
        () =>
          // xhr
          {
            // console.log((xhr.loaded / xhr.total) * 100 + '% loaded')
          },
        // called when loading has errors
        (err) => {
          console.log('An error happened', err);
        }
      );
    });
  }

  loadAudio(url, name, onAssetLoaded) {
    return new Promise((resolve) => {
      this.#AudioLoader.load(
        url,
        (result) => {
          this.#assets[name].audio = result;
          onAssetLoaded();
          resolve(result);
        },
        () => {},
        (err) => {
          console.error(`Failed to load audio: ${url}`, err);
        }
      );
    });
  }
}

export default new LoaderManager();
