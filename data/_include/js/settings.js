  Reveal.initialize({
    // Display controls in the bottom right corner
    controls: true,

    // Display a presentation progress bar
    progress: false,

    // Push each slide change to the browser history
    history: false,

    // Enable keyboard shortcuts for navigation
    keyboard: true,

    // Enable the slide overview mode
    overview: true,

    // Loop the presentation
    loop: false,

    // Number of milliseconds between automatically proceeding to the 
    // next slide, disabled when set to 0
    autoSlide: 0,

    // Enable slide navigation via mouse wheel
    mouseWheel: true,

    // Apply a 3D roll to links on hover
    rollingLinks: true,

   // Transition style
   transition: 'default', // default/cube/page/concave/linear(2d)
    
   theme: Reveal.getQueryHash().theme || 'thomas', // available themes are in /css/theme
   transition: Reveal.getQueryHash().transition || 'default', // default/cube/page/concave/linear(2d)

    // Optional libraries used to extend on reveal.js
    dependencies: [
      { src: 'lib/js/highlight.js', async: true, callback: function() { window.hljs.initHighlightingOnLoad(); } },
      { src: 'lib/js/classList.js', condition: function() { return !document.body.classList; } },
      { src: 'lib/js/showdown.js', condition: function() { return !!document.querySelector( '[data-markdown]' ); } },
      { src: 'lib/js/data-markdown.js', condition: function() { return !!document.querySelector( '[data-markdown]' ); } },
      { src: '/socket.io/socket.io.js', async: true, condition: function() { return window.location.host === 'localhost:1947'; } },
      { src: 'plugin/speakernotes/client.js', async: true, condition: function() { return window.location.host === 'localhost:1947'; } },
    ]
  });
  
  Reveal.addEventListener('slidechanged', function( event ) {
    // event.previousSlide, event.currentSlide, event.indexh, event.indexv
    
    var prevId = event.previousSlide.id;
    var curId = event.currentSlide.id;
    
    if ((prevId.indexOf('ex_') >= 0) && (curId === prevId + "_result")) {
      var srcId = prevId + "_src";
      var destId = prevId + "_dest";
      
      transfer(srcId, destId);
    }
    
    if (findChild(event.currentSlide, "src") && findChild(event.currentSlide, "dest")) {
      var element = findChild(event.currentSlide, "src");
      var eventHandler = findChild(event.currentSlide, "src").getAttribute("onclick");
      eval(eventHandler.replace(/this/g, "element"));
    }
});
