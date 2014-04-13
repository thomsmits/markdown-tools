# Chapter 2: Basic Code Handling

## Inline Code
  
Code can be embedded inline `int i = 0; i++` inside of the normal text. Programming language is controlled by `metadata.properties`.


## Fenced Code

Code can be embedded in the GitHub fenced code style with an indicator of the language.

```html  
<!DOCTYPE html>
<html lang="de">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <title>Meine erste Seite</title>
</head>
  
<body>
  <p>Ein Absatz</p>
</body>
  
</html>
```


## Normal Code

Instead of fenced code blocks, code indented by four spaces is supported. Programming language is taken from `metadata.properties` file.

    <h1>Überschrift auf Ebene 1</h1>
    <h2>Unterüberschrift</h2>
    
    <p>Ein Absatz mit etwas Text, wobei hier<br/>ein Zeilenumbruch 
    erzwungen wurde.</p>
    
    <p>Eine Definition gefällig: <dfn>Perl - The only language that 
    looks the same before and after RSA encryption.</dfn></p>


## Code with output

When the code generates output, the language `console` can be used.

```bash
echo "Hello World"
```

```console
Hello World
```


## Revealing output on the next slide

In case the output should be revealed on the next slide, it can be marked with a number indicating the display order, e.g. `[1]`. 0 is the default number for all elements.

```bash
echo "Hello World"
```

```console[1]
Hello World
```
