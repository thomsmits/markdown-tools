# Chapter 3: Live Code

## Restrictions

Live code only works if the slides are generated to the HTML format. It does not work for PDF generation.


## Link HTML between two slides (source)
  
Source

    <p>Example Code</p>


## Link HTML between two slides (result)

((Link-Previous))


## Live HTML on the same slide

    <b>bold</b><br>
    <i>italic</i><br>
    <tt>teletype</tt>

((Live-Preview))


## Execute JavaScript

    alert("Hello World!");
 
((Button))


## Execute JavaScript with logging

    var a = "10";
    
    log("typeof(a) = " + typeof(a)); 

((Button-With-Log))


## CSS Styling

<script>
var html6 = '<html><head><style>h1, p, q, em { font-size: 20pt; font-family: Helvetica, Arial, Sans-Serif };</style></head><body><p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. <span style="!!STYLE!!">Aenean commodo ligula eget dolor. Aenean massa.</span> Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim.</p></body></html>';
</script>

```css
display: inline; /* inline | block | none */
color: red;
```

((Live-CSS html6))


## HTML

HTML can be used (in case HTML slides are generated) to perform formatting not possible with Markdown. Like <span style='font-family: serif'>font selection</span>. Due to the fact that this does not work with PDF, the feature should be used carefully.

