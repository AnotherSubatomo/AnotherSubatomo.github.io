
`template.html`
```html
...
<main>
	{{CONTENT}}
</main>
...
```

`input.html`
```html
<CONTENT> <!-- non-standard tag; interpreted by the Bash templater as a placeholder substitute -->
	<h1>hi, im anosuba!</h1>
	<p>Paragraph content goes here!</p>
</CONTENT>
```

### `render.sh`
Usage goes as `render.sh <context-file> <output-path>`.

This script is responsible for using the information in the given `context-file` (e.g. the template being used, it's content, etc.) to transform the file at the `output-file`.