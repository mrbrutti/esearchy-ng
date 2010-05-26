Raphael.fn.connection = function (obj1, obj2, line, bg) {
    if (obj1.line && obj1.from && obj1.to) {
        line = obj1;
        obj1 = line.from;
        obj2 = line.to;
    }
    var bb1 = obj1.getBBox();
    var bb2 = obj2.getBBox();
    var p = [{x: bb1.x + bb1.width / 2, y: bb1.y - 1},
        {x: bb1.x + bb1.width / 2, y: bb1.y + bb1.height + 1},
        {x: bb1.x - 1, y: bb1.y + bb1.height / 2},
        {x: bb1.x + bb1.width + 1, y: bb1.y + bb1.height / 2},
        {x: bb2.x + bb2.width / 2, y: bb2.y - 1},
        {x: bb2.x + bb2.width / 2, y: bb2.y + bb2.height + 1},
        {x: bb2.x - 1, y: bb2.y + bb2.height / 2},
        {x: bb2.x + bb2.width + 1, y: bb2.y + bb2.height / 2}];
    var d = {}, dis = [];
    for (var i = 0; i < 4; i++) {
        for (var j = 4; j < 8; j++) {
            var dx = Math.abs(p[i].x - p[j].x),
                dy = Math.abs(p[i].y - p[j].y);
            if ((i == j - 4) || (((i != 3 && j != 6) || p[i].x < p[j].x) && ((i != 2 && j != 7) || p[i].x > p[j].x) && ((i != 0 && j != 5) || p[i].y > p[j].y) && ((i != 1 && j != 4) || p[i].y < p[j].y))) {
                dis.push(dx + dy);
                d[dis[dis.length - 1]] = [i, j];
            }
        }
    }
    if (dis.length == 0) {
        var res = [0, 4];
    } else {
        var res = d[Math.min.apply(Math, dis)];
    }
    var x1 = p[res[0]].x,
        y1 = p[res[0]].y,
        x4 = p[res[1]].x,
        y4 = p[res[1]].y,
        dx = Math.max(Math.abs(x1 - x4) / 2, 10),
        dy = Math.max(Math.abs(y1 - y4) / 2, 10),
        x2 = [x1, x1, x1 - dx, x1 + dx][res[0]].toFixed(3),
        y2 = [y1 - dy, y1 + dy, y1, y1][res[0]].toFixed(3),
        x3 = [0, 0, 0, 0, x4, x4, x4 - dx, x4 + dx][res[1]].toFixed(3),
        y3 = [0, 0, 0, 0, y1 + dy, y1 - dy, y4, y4][res[1]].toFixed(3);
    var path = ["M", x1.toFixed(3), y1.toFixed(3), "C", x2, y2, x3, y3, x4.toFixed(3), y4.toFixed(3)].join(",");
    if (line && line.line) {
        line.bg && line.bg.attr({path: path});
        line.line.attr({path: path});
    } else {
        var color = typeof line == "string" ? line : "#000";
        return {
            bg: bg && bg.split && this.path(path).attr({stroke: bg.split("|")[0], fill: "none", "stroke-width": bg.split("|")[1] || 3}),
            line: this.path(path).attr({stroke: color, fill: "none"}),
            from: obj1,
            to: obj2
        };
    }
};

var el;

window.onload = function () {
    var isDrag = false;
    var dragger = function (e) {
			this.dx = e.clientX;
    	this.dy = e.clientY;
    	isDrag = this;
    	this.animate({"fill-opacity": .2}, 500);
    	e.preventDefault && e.preventDefault();
    };

    var r = Raphael("holder", "100%", "90%");
		//var st = r.set().push( r.rect(450, 100, 60, 60, 5, 5), r.text(480, 130, "Matias"));
		//	  r.image("images/linkedin.gif", 190, 690, 30, 30 ),
		//	  r.image("images/spoke.gif", 290, 690, 60, 25 ),
		//	  r.image("images/googleprofile.png", 500, 300, 40, 40 ),
    var connections = [],
        shapes = [  r.set().push( r.rect(450, 100, 116, 60, 5, 5), r.text(508, 130, "@TEST.COM").attr({fill: '#fff', "font-size": 14})),
				r.image("images/linkedin.gif", 395, 185, 30, 30 ), 
				r.image("images/googleprofile.png", 530, 185, 40, 40 ),
				r.image("images/plaxo.gif", 270, 185, 30, 30 ),
	  		r.set().push( r.path("M 290 180 l 0 -20 l 160 0 l 0 20 l -160 0 l 0 60 l 160 0 l 0 -60 z"), r.text(370, 175, "John Doe")), 
				r.set().push( r.path("M 343 280 l 0 -20 l 160 0 l 0 20 l -160 0 l 0 60 l 160 0 l 0 -60 z"),r.text(423, 275, "Mike Moler")),
				r.set().push( r.path("M 450 600 l 0 -20 l 160 0 l 0 20 l -160 0 l 0 60 l 160 0 l 0 -60 z"),r.text(530, 595, "Ernest Soler")),
	  		r.set().push( r.path("M 50 60 l 0 -20 l 160 0 l 0 20 l -160 0 l 0 60 l 160 0 l 0 -60 z"), r.text(130, 55, "Vicky Stivy")),
	  		r.set().push( r.path("M 600 100 l 0 -20 l 160 0 l 0 20 l -160 0 l 0 60 l 160 0 l 0 -60 z"), r.text(680, 95, "Steve Smart")),
	  		r.set().push( r.path("M 600 100 l 0 -20 l 160 0 l 0 20 l -160 0 l 0 60 l 160 0 l 0 -60 z"), r.text(680, 95, "Steve Smart")),
				r.set().push( r.path("M 343 280 l 0 -20 l 160 0 l 0 20 l -160 0 l 0 60 l 160 0 l 0 -60 z"),r.text(423, 275, "Mike Moler")),
				r.set().push( r.path("M 450 600 l 0 -20 l 160 0 l 0 20 l -160 0 l 0 60 l 160 0 l 0 -60 z"),r.text(530, 595, "Ernest Soler")),
	  		r.set().push( r.path("M 50 60 l 0 -20 l 160 0 l 0 20 l -160 0 l 0 60 l 160 0 l 0 -60 z"), r.text(130, 55, "Vicky Stivy")),
	  		r.set().push( r.path("M 600 100 l 0 -20 l 160 0 l 0 20 l -160 0 l 0 60 l 160 0 l 0 -60 z"), r.text(680, 95, "Steve Smart")),
	  		r.set().push( r.path("M 600 100 l 0 -20 l 160 0 l 0 20 l -160 0 l 0 60 l 160 0 l 0 -60 z"), r.text(680, 95, "Steve Smart"))
                ];
    for (var i = 0, ii = shapes.length; i < ii; i++) {
        var color = Raphael.getColor();
        shapes[i].attr({fill: color, stroke: color, "fill-opacity": 0.5, "stroke-width": 2});
        //shapes[i].node.style.cursor = "move";
        shapes[i].mousedown(dragger);
    }
    connections.push(r.connection(shapes[0], shapes[1], "#fff", "#fff|3"));
    connections.push(r.connection(shapes[0], shapes[2], "#fff", "#fff|3"));
    connections.push(r.connection(shapes[0], shapes[3], "#fff", "#fff|3"));
    connections.push(r.connection(shapes[1], shapes[4], "#fff", "#fff|3"));
    connections.push(r.connection(shapes[2], shapes[5], "#fff", "#fff|3"));
    connections.push(r.connection(shapes[3], shapes[6], "#fff", "#fff|3"));
    connections.push(r.connection(shapes[1], shapes[7], "#fff", "#fff|3"));
    connections.push(r.connection(shapes[2], shapes[8], "#fff", "#fff|3"));
    connections.push(r.connection(shapes[3], shapes[9], "#fff", "#fff|3"));
    connections.push(r.connection(shapes[2], shapes[10], "#fff", "#fff|3"));
    connections.push(r.connection(shapes[1], shapes[11], "#fff", "#fff|3"));
    connections.push(r.connection(shapes[2], shapes[12], "#fff", "#fff|3"));
    connections.push(r.connection(shapes[2], shapes[13], "#fff", "#fff|3"));
		connections.push(r.connection(shapes[3], shapes[14], "#fff", "#fff|3"));
    
		
		document.onmousemove = function (e) {
        e = e || window.event;
        if (isDrag) {
					if (isDrag.set) {
						isDrag.set.translate(e.clientX - isDrag.dx, e.clientY - isDrag.dy);
					}
					else { isDrag.translate(e.clientX - isDrag.dx, e.clientY - isDrag.dy); }
					//st.translate(e.clientX - isDrag.dx, e.clientY - isDrag.dy);
	        for (var i = connections.length; i--;) {
	         		r.connection(connections[i]);
	        }
	        r.safari();
					if (isDrag.set) {
						isDrag.dx = e.clientX;
		        isDrag.dy = e.clientY;
					}
	        else {
						isDrag.dx = e.clientX;
	        	isDrag.dy = e.clientY;
					}
        }
    };
    document.onmouseup = function () {
        isDrag && isDrag.animate({"fill-opacity": 0.5}, 500);
        isDrag = false;
    };
};
