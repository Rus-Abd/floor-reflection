import './style.css';

import { gsap } from 'gsap';
import * as THREE from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { Reflector } from 'three/addons/objects/Reflector.js';
import { SHADERS } from './constants';

import groundVertShader from './shaders/groundShader/vert.glsl';

import groundFragShader from './shaders/groundShader/frag.glsl';
import LoaderManager from './utils/LoaderManager';

const sizes = {
  width: window.innerWidth,
  height: window.innerHeight,
};
const googleAnalyticsMeasurementId = import.meta.env
  .VITE_GOOGLE_ANALYTICS_MEASUREMENT_ID;

class App {
  constructor() {
    this.width = sizes.width;
    this.height = sizes.height;
    this.container = document.getElementById('app');
    this.scene = new THREE.Scene();
    this.renderer = new THREE.WebGLRenderer();
    this.container.appendChild(this.renderer.domElement);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.setClearAlpha(0xeeeeee, 1);
    this.renderer.setSize(this.width, this.height);

    this.camera = new THREE.PerspectiveCamera(
      70,
      this.width / this.height,
      0.01,
      1000
    );

    this.camera.position.set(-2.475, 1.1853, 2.5997);
    this.camera.rotation.set(-0.10418, -0.4094, -0.0416);

    this.time = 0;
    this.percentageLoaded = 0;
    this.clock = new THREE.Clock();

    this.gltfLoader = new GLTFLoader();
    this.textureLoader = new THREE.TextureLoader();

    this.currentShaderIndex = 0;
    this.init();
  }

  init = async () => {
    const assets = [
      {
        name: 'waterdudv',
        texture: 'waterdudv.jpg',
      },
      {
        name: 'flower',
        gltf: 'flower.glb',
      },
      {
        name: 'spider',
        gltf: 'spider.glb',
      },
      { name: 'noise', texture: 'noise.png' },
      { name: 'bg-music', audio: 'bg.mp3' },
    ];

    await LoaderManager.load(assets, (percentageLoaded) => {
      this.percentageLoaded = percentageLoaded;
      if (this.percentageLoaded === 100) {
        const button = document.querySelector('.continue');
        button.style.display = 'flex';
        button.addEventListener(
          'click',
          () => {
            this.listener = new THREE.AudioListener();
            this.camera.add(this.listener);
            const loadingScreen = document.querySelector('.loading-screen');
            loadingScreen.style.display = 'none';
            const audioBuffer = LoaderManager.assets['bg-music'].audio;
            const bgMusic = new THREE.Audio(this.listener);
            bgMusic.setBuffer(audioBuffer);
            bgMusic.setLoop(true); // Set to true if you want the audio to loop
            bgMusic.play();
          },
          { once: true }
        );
      }
    });
    this.addGtag();
    this.addObjects();
    this.addLights();
    this.resize();
    this.render();
    this.setupResize();
    this.ShaderModeHandler();
    this.addResponsiveness();
  };

  setupResize() {
    window.addEventListener('resize', this.resize.bind(this));
  }

  resize() {
    this.width = this.container.offsetWidth;
    this.height = this.container.offsetHeight;
    this.renderer.setSize(this.width, this.height);
    this.camera.aspect = this.width / this.height;
    this.camera.updateProjectionMatrix();
  }

  addObjects() {
    const texture = LoaderManager.assets['noise'].texture;
    this.material = new THREE.ShaderMaterial({
      side: THREE.DoubleSide,
      uniforms: {
        time: { value: 0 },
        resolution: { value: new THREE.Vector4() },
        texture1: { value: texture },
      },
      fragmentShader: SHADERS[0][0],
      vertexShader: SHADERS[0][1],
    });

    const screen = new THREE.Mesh(new THREE.PlaneGeometry(7, 4), this.material);

    screen.position.z = -7;
    screen.position.y = 2;

    this.scene.add(screen);

    const flower = LoaderManager.assets['flower'].gltf.scene;
    flower.children[0].material = this.material;
    flower.position.set(0, 1, 0);
    this.scene.add(flower);

    const dudvMap = LoaderManager.assets['waterdudv'].texture;
    dudvMap.wrapS = dudvMap.wrapT = THREE.RepeatWrapping;

    const planeGeometry = new THREE.PlaneGeometry(10, 10);

    this.customShader = Reflector.ReflectorShader;
    this.customShader.fragmentShader = groundFragShader;
    this.customShader.vertexShader = groundVertShader;

    this.customShader.uniforms.tDudv = { value: dudvMap };
    this.customShader.uniforms.time = { value: 0 };

    this.plane = new Reflector(planeGeometry, {
      shader: this.customShader,
      clipBias: 0.003,
      textureWidth: window.innerWidth,
      textureHeight: window.innerHeight,
      color: 0x000000,
    });
    this.plane.rotateX(-Math.PI / 2);
    this.scene.add(this.plane);

    this.monster = LoaderManager.assets['spider'].gltf.scene;
    this.mixer = new THREE.AnimationMixer(this.monster);
    this.monsterAnimation = this.mixer.clipAction(
      LoaderManager.assets['spider'].gltf.animations[3]
    );
    this.monsterAnimation.play();

    this.monster.position.set(-9, 0.1, -3);

    this.monster.rotation.y = Math.PI / 2;

    gsap.to(this.monster.position, {
      duration: 8,
      x: 5,
      repeat: -1,
      yoyo: true,
      onRepeat: () => {
        this.monster.rotateY(Math.PI);
      },
    });

    this.scene.add(this.monster);
  }

  addLights() {
    const light2 = new THREE.DirectionalLight(0xffffff, 0.05);
    light2.position.set(0.5, 0, 0.866);
    this.scene.add(light2);
  }

  render() {
    this.time = this.clock.getDelta();

    this.material.uniforms.time.value += this.time * 2;
    this.customShader.uniforms.time.value += this.time * 2;

    if (this.mixer) {
      this.mixer.update(this.time);
    }

    this.renderer.render(this.scene, this.camera);
    window.requestAnimationFrame(this.render.bind(this));
  }

  ShaderModeHandler() {
    this.buttons = document.querySelectorAll('button');

    window.addEventListener('click', (e) => {
      if (e.target.className === 'mode-button') {
        if (e.target.innerText === 'DEFAULT') {
          this.material.fragmentShader = SHADERS[0][0];
          this.material.vertexShader = SHADERS[0][1];
        } else {
          const index = e.target.innerText.split(' ')[1];
          this.material.fragmentShader = SHADERS[index][0];
          this.material.vertexShader = SHADERS[index][1];
        }

        this.material.needsUpdate = true;
      }
    });
  }

  addResponsiveness() {
    if (this.width < 600) {
      this.camera.fov = 90;
      this.camera.position.z = 3.3;
      this.camera.position.x = -2.975;
      this.camera.updateProjectionMatrix();
    }
  }

  addGtag() {
    if (googleAnalyticsMeasurementId) {
      const script = document.createElement('script');
      script.async = true;
      script.src = `https://www.googletagmanager.com/gtag/js?id=${googleAnalyticsMeasurementId}`;
      document.head.appendChild(script);

      script.onload = () => {
        window.dataLayer = window.dataLayer || [];
        function gtag() {
          window.dataLayer.push(arguments);
        }
        gtag('js', new Date());
        gtag('config', googleAnalyticsMeasurementId, { allow_linker: true });
      };
    }
  }
}
new App();
