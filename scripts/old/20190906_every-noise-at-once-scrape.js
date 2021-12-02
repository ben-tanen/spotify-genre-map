var genres = document.getElementsByClassName("genre");
var genres_bt = [ ]

for (let i = 0; i < genres.length; i++) {
	let g = genres[i];
	genres_bt.push({
		'genre': g.innerText,
		'color': g.style.color,
		'size': g.style.fontSize,
		'left': g.style.left,
		'top': g.style.top
	})
}

var textDoc = document.createElement('a');
textDoc.href = 'data:attachment/text,' + encodeURI(JSON.stringify(genres_bt));
textDoc.target = '_blank';
textDoc.download = 'every-noise-at-once-scrape.txt';
textDoc.click();