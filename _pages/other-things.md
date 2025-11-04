---
layout: archive
title: "Design & web development"
permalink: /other-things/
author_profile: true
---

{% include base_path %}

I discovered my passion for building things as an undergraduate psychology student programming psychophysics experiments. It's what drew me to UX research initially, where I helped design the in-app interface and bag labels that delivery drivers use when you order a late-night snack from <a href="https://www.gopuff.com/" target="_blank" style="text-decoration: none;"><span style="font-weight: bold; color: #00A4FF;">Gopuff</span></a>.

<div style="display: flex; align-items: center; justify-content: center; margin-top: 20px; margin-bottom: 20px; gap: 10px; flex-wrap: nowrap; overflow-x: auto; max-width: 100%; padding: 10px 0;">
  <img src="{{ base_path }}/files/A-app.png" alt="App A" style="height: 240px; width: auto; display: block; flex-shrink: 0;">
  <img src="{{ base_path }}/files/A-label.png" alt="Label A" style="height: 170px; width: auto; display: block; flex-shrink: 0;">
  <img src="{{ base_path }}/files/B-app.png" alt="App B" style="height: 240px; width: auto; display: block; flex-shrink: 0;">
  <img src="{{ base_path }}/files/B-label.png" alt="Label B" style="height: 170px; width: auto; display: block; flex-shrink: 0;">
  <img src="{{ base_path }}/files/C-app.png" alt="App C" style="height: 240px; width: auto; display: block; flex-shrink: 0;">
  <img src="{{ base_path }}/files/C-label.png" alt="Label C" style="height: 170px; width: auto; display: block; flex-shrink: 0;">
</div>

While most of the websites and platforms I've built since then have been research-focused (like the simulated social media feed below), my latest 'for fun' project was a simple meditation website that lets you play custom background music from YouTube and track your practice hours over time. 

You can try it out <a href="https://meditationflower.onrender.com/" target="_blank" style="text-decoration: none;"><span style="font-weight: bold; color: #9966CC;">here!</span></a>

<div style="display: flex; align-items: center; justify-content: center; margin-top: 40px; gap: 35px; flex-wrap: nowrap; overflow-x: auto;">
  <div style="flex: 0 0 320px; min-width: 0;">
    <video id="video1" autoplay loop muted playsinline controls preload="auto" style="width: 100%; height: auto; border: 1px solid #ccc; border-radius: 10px; display: block;">
      <source src="{{ base_path }}/files/rateTweets-scroll.mp4" type="video/mp4">
      Your browser does not support the video tag.
    </video>
  </div>
  <div style="flex: 0 0 auto; min-width: 0;">
    <video id="video2" autoplay loop muted playsinline controls preload="auto" style="width: auto; height: auto; max-width: 600px; border: 1px solid #ccc; border-radius: 10px; display: block;">
      <source src="{{ base_path }}/files/meditation-flower.mp4" type="video/mp4">
      Your browser does not support the video tag.
    </video>
  </div>
  <!-- Add more video squares here -->
</div>

<script>
  // Ensure videos autoplay and loop
  document.addEventListener('DOMContentLoaded', function() {
    var video1 = document.getElementById('video1');
    var video2 = document.getElementById('video2');
    
    console.log('Video elements found:', {video1: !!video1, video2: !!video2});
    
    // Setup video1
    if (video1) {
      video1.addEventListener('loadedmetadata', function() {
        console.log('Video1 metadata loaded:', video1.videoWidth, 'x', video1.videoHeight);
      });
      video1.addEventListener('error', function(e) {
        console.error('Video1 error:', e, video1.error);
      });
      video1.addEventListener('ended', function() {
        video1.currentTime = 0;
        video1.play();
      });
      video1.play().catch(function(error) {
        console.log('Autoplay blocked for video1:', error);
      });
    }
    
    // Setup video2 with monitoring and recovery
    if (video2) {
      var video2WasPlaying = false;
      var video2HasLoaded = false;
      var video2IsReloading = false;
      var video2LastReload = 0;
      var reloadCooldown = 30000; // Only reload once every 30 seconds max
      
      // Initial debugging
      console.log('Video2 initial state - readyState:', video2.readyState, 'networkState:', video2.networkState);
      console.log('Video2 source:', video2.querySelector('source')?.src);
      console.log('Video2 currentSrc:', video2.currentSrc);
      
      // Don't force load() - let the browser handle it naturally with autoplay attribute
      
      video2.addEventListener('loadstart', function() {
        console.log('Video2 loadstart event fired');
      });
      
      video2.addEventListener('loadedmetadata', function() {
        console.log('Video2 metadata loaded:', video2.videoWidth, 'x', video2.videoHeight);
        video2HasLoaded = true;
        video2IsReloading = false;
        // Try to play once loaded
        video2.play().catch(function(error) {
          console.log('Video2 autoplay blocked after metadata, will try again');
        });
      });
      
      video2.addEventListener('canplay', function() {
        // Try to play when video can start playing
        if (video2.paused) {
          video2.play().catch(function(error) {
            console.log('Video2 autoplay blocked after canplay:', error);
          });
        }
      });
      
      video2.addEventListener('canplaythrough', function() {
        // Try to play when video has buffered enough
        if (video2.paused) {
          video2.play().catch(function(error) {
            console.log('Video2 autoplay blocked after canplaythrough:', error);
          });
        }
      });
      
      video2.addEventListener('play', function() {
        video2WasPlaying = true;
        video2IsReloading = false;
      });
      
      video2.addEventListener('pause', function() {
        video2WasPlaying = false;
      });
      
      video2.addEventListener('waiting', function() {
        // Don't log this constantly, it's normal buffering behavior
      });
      
      video2.addEventListener('stalled', function() {
        var now = Date.now();
        if (!video2IsReloading && (now - video2LastReload) > reloadCooldown) {
          console.log('Video2 stalled, attempting recovery');
          video2IsReloading = true;
          video2LastReload = now;
          video2.load();
          setTimeout(function() {
            video2.play().catch(function(error) {
              console.log('Video2 recovery play failed:', error);
            });
          }, 500);
        }
      });
      
      video2.addEventListener('error', function(e) {
        console.error('Video2 error event fired');
        if (video2.error) {
          console.error('Video2 error code:', video2.error.code);
          console.error('Video2 error message:', video2.error.message);
          // Error codes: 1=MEDIA_ERR_ABORTED, 2=MEDIA_ERR_NETWORK, 3=MEDIA_ERR_DECODE, 4=MEDIA_ERR_SRC_NOT_SUPPORTED
        }
        console.error('Video2 currentSrc:', video2.currentSrc);
        console.error('Video2 readyState:', video2.readyState);
        console.error('Video2 networkState:', video2.networkState);
        
        var now = Date.now();
        if (!video2IsReloading && (now - video2LastReload) > reloadCooldown) {
          // Try to recover from error, but only if we haven't reloaded recently
          video2IsReloading = true;
          video2LastReload = now;
          setTimeout(function() {
            console.log('Attempting to reload video2 after error');
            video2.load();
            setTimeout(function() {
              video2.play().catch(function(error) {
                console.log('Video2 recovery play after error failed:', error);
                video2IsReloading = false;
              });
            }, 500);
          }, 1000);
        }
      });
      
      video2.addEventListener('ended', function() {
        video2.currentTime = 0;
        video2.play();
      });
      
      // Periodic check to detect when video goes black/becomes invisible
      var lastVideoTime = 0;
      var blackScreenDetected = 0;
      setInterval(function() {
        // Only check if video was previously loaded and working
        if (!video2HasLoaded) return;
        
        // Check if video is playing but time isn't advancing (black screen indicator)
        if (!video2.paused && video2.readyState >= 2) {
          var currentTime = video2.currentTime;
          // If video time hasn't advanced in 2 seconds and it should be playing, it might be black
          if (Math.abs(currentTime - lastVideoTime) < 0.1 && lastVideoTime > 0) {
            blackScreenDetected++;
            if (blackScreenDetected >= 3) { // Detected black screen for 3 checks (30 seconds)
              console.log('Video2 appears to be black/frozen, reloading...');
              blackScreenDetected = 0;
              var now = Date.now();
              if (!video2IsReloading && (now - video2LastReload) > reloadCooldown) {
                video2IsReloading = true;
                video2LastReload = now;
                video2.load();
                setTimeout(function() {
                  video2.play().catch(function(error) {
                    console.log('Video2 play after black screen reload failed:', error);
                    video2IsReloading = false;
                  });
                }, 500);
              }
            }
          } else {
            blackScreenDetected = 0; // Reset counter if time is advancing
          }
          lastVideoTime = currentTime;
        }
        
        // Check if video should be playing but isn't (only if it was playing before)
        if (video2.readyState >= 2 && video2.paused && video2WasPlaying && !video2IsReloading) {
          console.log('Video2 unexpectedly paused, attempting to resume');
          video2.play().catch(function(error) {
            console.log('Video2 resume failed:', error);
          });
        }
      }, 10000); // Check every 10 seconds
      
      // Try to play initially after delays to let load() complete
      setTimeout(function() {
        console.log('Video2 initial play attempt (500ms) - readyState:', video2.readyState, 'networkState:', video2.networkState);
        if (video2.paused) {
          video2.play().catch(function(error) {
            console.log('Video2 initial play blocked (500ms):', error);
          });
        }
      }, 500);
      
      setTimeout(function() {
        console.log('Video2 play attempt (2s) - readyState:', video2.readyState, 'networkState:', video2.networkState);
        if (video2.paused && video2.readyState >= 2) {
          video2.play().catch(function(error) {
            console.log('Video2 play blocked (2s):', error);
          });
        }
      }, 2000);
      
      // Try to play on user interaction (click, scroll, keypress, etc.)
      // This handles browsers that block autoplay until user interaction
      var tryPlayOnInteraction = function() {
        if (video2.paused && video2.readyState >= 2) {
          video2.play().then(function() {
            console.log('Video2 started playing after user interaction');
          }).catch(function(error) {
            console.log('Video2 play after user interaction failed:', error);
          });
        }
      };
      
      // Listen for various user interactions
      document.addEventListener('click', tryPlayOnInteraction, { once: true });
      document.addEventListener('scroll', tryPlayOnInteraction, { once: true });
      document.addEventListener('keydown', tryPlayOnInteraction, { once: true });
      document.addEventListener('touchstart', tryPlayOnInteraction, { once: true });
    }
  });
</script>

