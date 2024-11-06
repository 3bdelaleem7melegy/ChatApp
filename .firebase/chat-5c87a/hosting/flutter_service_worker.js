'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "27dd30f5994771502a9f3895bb803de1",
"assets/AssetManifest.bin.json": "1397390218a0e2961fb48a3cc29b35db",
"assets/AssetManifest.json": "c3c09fd9f6f66574e348fe3e9412bc43",
"assets/assets/12.jpg": "0ecc0d203c0ad2c8b2755e1759b7e84a",
"assets/assets/14.jpg": "a3619ab754103df738219240aa827ea9",
"assets/assets/19834-bg.png": "fbd69e80f5d40650894a6b9bbdd5cb76",
"assets/assets/19834.jpg": "d0c42102720aeaaba4d67d9db85962b8",
"assets/assets/19835.jpg": "3b47d6a72fdaa1fc8ce0064bd5ff9ffe",
"assets/assets/414-bg.png": "3ec7eb150c92f1723a8b20bce5336e67",
"assets/assets/414.jpg": "2864168dd1131f0e9ed5181885fa85a2",
"assets/assets/55.jpg": "1405dd573f3324c6b58717bcd8edce07",
"assets/assets/555.jpg": "653e3d81bab274d90079e7f0a26df992",
"assets/assets/83b2ea14ed61dc8fa9a3e5ae2ca81c0f.svg": "3296d6ad61e7d9d93f63a55323670705",
"assets/assets/appointment.jpg": "353ad09f1935e278b153292909b181e2",
"assets/assets/Bone%2520Rumor.jpg": "3b2241470fa84a7cc84f62113f988383",
"assets/assets/Brain%2520Rumor.jpg": "933bc31902e9ee63af7de0468689be41",
"assets/assets/cardiologist.png": "d45a05ca8d1e4f88406028a12e95b60b",
"assets/assets/covid-bg.png": "0ed1d84cebe210fed9e9e7298db62fce",
"assets/assets/covid.jpg": "812313a2154017b674f3e34879728dc0",
"assets/assets/CT%2520scan.jpg": "732f0ab86e79cf3b33113b0bd02a67ab",
"assets/assets/customer-service.jpg": "7460972c7293167cfb4d746526d10d44",
"assets/assets/dentistry.png": "da9aae68e95efa54ad42e90166c2df81",
"assets/assets/disease.png": "7af4b09b2db5e3aa09e86816f93bfa3f",
"assets/assets/doc.png": "8db37d2d132fd907aa5afed6572248aa",
"assets/assets/doctor-consulting-with-patient-vector.webp": "130dcfb8c31db72b6215d16713f6228e",
"assets/assets/download%2520(1).jpg": "9808f193e6358fd832ab6b1200430d22",
"assets/assets/download.jpg": "ef0cb89c963d200de74706572f2b6d18",
"assets/assets/Echo%2520Rumour.jpg": "d8c259018449dce8a1145197ce2646a4",
"assets/assets/error-404.jpg": "b16e717f48017de9d05055bcbc649ef9",
"assets/assets/examination.jpg": "23fb5b153908847e34e171aa086cc53c",
"assets/assets/Heart%2520Rumor.jpg": "2acb37e8097612c0612380df524db307",
"assets/assets/how-is-skin-cancer-diagnosed-722x406.jpg": "f6367cec2ad0c313f2e900883a504dd2",
"assets/assets/image-medical-2.jpg": "e9d5296f94cfaabe314e8502d701afbf",
"assets/assets/image-medical-3.jpg": "4aafe9c6a606f10d64a3b86c2f84a168",
"assets/assets/image-medical.jpg": "bf182e4d6a98fd7077de141289917ebd",
"assets/assets/images%2520(1).jpg": "b0cf53763deac2f8ac484dfb8bf86227",
"assets/assets/images%2520(2).jpg": "d47d141552a7ade28e4f6a83303d44ce",
"assets/assets/images%2520(3).jpg": "c78860c4d42acea217989559c37e9a79",
"assets/assets/images%2520(4).jpg": "2b5f98ba123e06089eaaf23445afd8cc",
"assets/assets/images%2520(5).jpg": "8e6bad4c88bfb923c57692926a1204da",
"assets/assets/images%2520(6).jpg": "3f17605c06c2c7a2777bc0cae60e0137",
"assets/assets/images.jpg": "d1ea55b8b0359c197f4be169e4080c81",
"assets/assets/IMG_20220915_190800_700.jpg": "d7819799b66211593290dc1e2bfa0cfb",
"assets/assets/IMG_20230216_035602_989.png": "eed67cfbb2311422df318abbbacf35bf",
"assets/assets/Lab6.jpg": "5beca1963c81016b3ab0da7a0c88ca01",
"assets/assets/Labs.jpg": "02fa7f605d7d61f2bffa9bbe5938fc37",
"assets/assets/Labs2.jpg": "085766a923f2dae285065c7e21769ba4",
"assets/assets/Labs3.jpg": "769ccf8efc04814186a716fa8d85e48e",
"assets/assets/Labs4.jpg": "d57b19e55ac73e3a30d53a5478933b4b",
"assets/assets/Labs5.jpg": "7dfade2346b7853cee04b9b1f9bab081",
"assets/assets/Medic.ly_poster1.png": "e6515eb051c8b1447663e0be9ee30072",
"assets/assets/medical-red.png": "4ccb692d39e157848b70fa909fd9f83c",
"assets/assets/ophthalmologist.png": "d4d1dd0980f69f71d17aae75eb2532b1",
"assets/assets/orthopedics.png": "d8f111f6104fba6efed6f8f6682999e4",
"assets/assets/person.jpg": "307a5a4db274d339b081bd279e45da99",
"assets/assets/personas-vector-set.jpg": "a585b1e8e51031f075dca6a7d4992c31",
"assets/assets/poster2.png": "5f463830d8853402b864823e08bf8e3c",
"assets/assets/Rumors.jpg": "41867f4ed8b4a7c3cfb0d9e4166ffca6",
"assets/assets/Screenshot_1708487728.png": "622fc1c2732768d3d19a53df1bf0a0d8",
"assets/assets/search-bg.png": "ae90c5256c8dc9e86b0d03396d94a3ef",
"assets/assets/search.jpg": "384e7f01b45948444d449239eedb6151",
"assets/assets/select-all.png": "d1ec9b23b07f07bb2f1f2704db5d42c4",
"assets/assets/vector-doc.jpg": "232a7dadc456d22a133e9a7fa3c7cccf",
"assets/assets/vector-doc2.jpg": "3b086051b7799d1f8c3ca73e10c0fe5a",
"assets/assets/video-call.jpg": "e4901b9971ce310e49ea29d51b3b2f76",
"assets/assets/virus.jpg": "3ea398a353d0e47afc41dda1cb4f250e",
"assets/FontManifest.json": "03517a6684061a94f8198eaf8dfbd717",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/NOTICES": "b7432fd1a4ea4bb30a5a2b5c4d8e70c0",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "b93248a553f9e8bc17f1065929d5934b",
"assets/packages/flutter_sound_web/howler/howler.js": "3030c6101d2f8078546711db0d1a24e9",
"assets/packages/flutter_sound_web/src/flutter_sound.js": "cf2794bc3b332910738b9fd2c398eafc",
"assets/packages/flutter_sound_web/src/flutter_sound_player.js": "ea66dcacd4bddd78cb158a998a57bdb3",
"assets/packages/flutter_sound_web/src/flutter_sound_recorder.js": "890bfbba1fd527173684fc2e3352718c",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "4769f3245a24c1fa9965f113ea85ec2a",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "3ca5dc7621921b901d513cc1ce23788c",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "a2eb084b706ab40c90610942d98886ec",
"assets/packages/iconly/fonts/IconlyBold.ttf": "128714c5bf5b14842f735ecf709ca0d1",
"assets/packages/iconly/fonts/IconlyBroken.ttf": "6fbd555150d4f77e91c345e125c4ecb6",
"assets/packages/iconly/fonts/IconlyLight.ttf": "5f376412227e6f8450fe79aec1c2a800",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"flutter_bootstrap.js": "8efb86ecb564cb9381d8d8aa6475aaaf",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "576b1fcfc3f93f27beeb955c3f5bddb7",
"/": "576b1fcfc3f93f27beeb955c3f5bddb7",
"main.dart.js": "860a29b63bd1bd44201439d01dd96c0a",
"manifest.json": "889028ff2bc5b9ee93364ba7cff70e03",
"version.json": "de197ad1e63c9ca340d707c221b79811"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
