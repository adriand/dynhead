function render() {
  // draw the table based on x and ylimits
  for (i = 0;i < this.ylimit;i++) {
    cells = "";
    for (j = 0;j < this.xlimit;j++) {
      cells += "<td></td>";
    }
    $("<tr>" + cells + "</tr>").appendTo(this.table);
  }
  
  this.xwidth = Math.round($(this.table).width() / this.xlimit);
  $(this.table + " tr td").css({ "width" : this.xwidth + "px", "height" : this.xwidth + "px" });
}

// TODO: use an options hash here
function update(x, y, opacity, colour, post_to_server) {
  if (!colour) { colour = "white"; }
  if (!opacity) { opacity = 1; }
  if (post_to_server) {
    $.post(this.dback + "/update", { x: x / this.xwidth, y: y / this.xwidth }, function(data) { });
  }
  // correct widths so the placed object is centered (since it is placed according to top-left coordinate)
  var width_correction = this.unit_width / 2;
  x -= width_correction;
  y -= width_correction;
  $("<img class='unit' src='" + colour + ".png' />").css({ "left":x + "px", "top":y + "px" }).appendTo(this.container).fadeTo("slow", opacity);
}

// load grid data points from web service
function load_points() {
  var gv = this;
  // last_update = last_update.toString();
  
  if (last_update != "") {
    // epochs
    last_update = Math.round(last_update.getTime() / 1000.0)
  }
  
  $.get(this.dback + "/points", { last_update: last_update }, function(data) {
    var items = eval(data);
    $.each(items, function(i,item) {
      // TODO: add opacity in, with item.opacity
      gv.update(item.x * gv.xwidth, item.y * gv.xwidth, item.opacity / 100);
    });
    // for vanity's sake
    load_signature();
  });
  last_update = new Date;
}

// TODO: redefine the function definition to take an options hash instead
function GridView(xlimit, ylimit, dback, table, container, unit_width) {
  this.xlimit = xlimit;
  this.ylimit = ylimit;
  this.dback = dback;  
  this.table = table;
  this.container = container;
  this.unit_width = unit_width;
  this.xwidth = 0;
  
  // methods
  this.render = render;
  this.update = update;
  this.load_points = load_points; 
  
  // events
  $(this.table).bind("click", { grid_view : this }, click_update);
}

// not part of any object
function click_update(e) {
  // clicks should snap to grid  
  // do this by dividing by xwidth, rounding the result, then multiplying by that
  var x = (e.pageX - $(grid_view.container).offset().left);
  x = Math.round(x / grid_view.xwidth) * grid_view.xwidth;
	var y = (e.pageY - $(grid_view.container).offset().top);
	y = Math.round(y / grid_view.xwidth) * grid_view.xwidth;
	
	grid_view.update(x, y, null, null, true);
}

function load_signature() {
  // hard-coded signature, drawn in the header
  signature = [{"y":14,"opacity":100,"x":2},{"y":13,"opacity":100,"x":3},{"y":12,"opacity":100,"x":4},{"y":13,"opacity":100,"x":5},{"y":14,"opacity":100,"x":6},{"y":14,"opacity":100,"x":4},{"y":14,"opacity":100,"x":8},{"y":12,"opacity":100,"x":8},{"y":13,"opacity":100,"x":10},{"y":14,"opacity":100,"x":12},{"y":12,"opacity":100,"x":12},{"y":13,"opacity":100,"x":13},{"y":14,"opacity":100,"x":14},{"y":12,"opacity":100,"x":14}];
  
  $.each(signature, function(i, points) {
    grid_view.update(points.x * grid_view.xwidth, points.y * grid_view.xwidth, 1, "black");
  });
}

var grid_view;
var last_update;