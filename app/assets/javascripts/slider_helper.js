$(document).ready(function(){
  values=[175000,180000]
  // Initialize slider
  $('#genomeSlider').noUiSlider({
    start: [values[0]],
    behaviour: 'tap-drag',
    range: {'min': 0,
	    'max': 192000
    },
    step: 1
  },true);
  var gslider = $( '#genomeSlider' );
  gslider.Link('lower').to($( '#start' ));
  $('#lengthSlider').noUiSlider({
    start: [values[1]-values[0]],
    behaviour: 'tap-drag',
    range: {'min': 100,
	    'max': 50000
    },
    step: 1
  },true);
  var lslider = $( '#lengthSlider' );
  // Create links

  $('.slider').on('set',function(){
    pos=Number(gslider.val())
    delta=Number(lslider.val())
    values = [pos,pos+delta];
    $('#start').val(values[0]);
    $('#end').val(d3.min([values[1],]));
  });



  $('#genomeSlider').Link('lower').to('-inline-<div class="slideTooltip"></div>',function(value){
    $(this).html(
      '<strong>Start : </strong>'+
	'<span>' + Math.floor(value) + '</span>'
      );
  });

  $('#lengthSlider').Link('lower').to('-inline-<div class="slideTooltip"></div>',function(value){
    $(this).html(
      '<strong>Length : </strong>'+
	'<span>' + Math.floor(value) + '</span>'
      );
  });


  // Adjusts range to chromosome
  var chr;
  d3.select('#chrSelect').on('change',function(d){
    chr=this;
    if (chr.value === "Chrom") {
      d3.select("#start").attr(
	{min: "0",
	 max: "3940880",
	 step: "1"
	});
      d3.select("#end").attr(
	{min: "0",
	 max: "3940880",
	 step: "1"
	});
      $('#genomeSlider').noUiSlider({range: {'min': 0,'max': 3940880}},true);
    } else {
      d3.select("#start").attr(
	{min: "0",
	 max: "192000",
	 step: "1"
	});
      d3.select("#end").attr(
	{min: "0",
	 max: "192000",
	 step: "1"
	});
      $('#genomeSlider').noUiSlider({range: {'min': 0,'max': 192000}},true)
    };
  });

  cond = d3.select("#cov").on("change",function(d){
    $('#cov').prop("checked") ? d3.selectAll(".cond").classed("hidden",false) : d3.selectAll(".cond").classed("hidden",true);
  })

  d3.select("#time1").on("change",function(d){
    if ($('#time1').val() == '75' || $('#time1').val() == '270') {
      $('#tex1').removeAttr("disabled");
    } else {
      $('#tex1').attr("disabled",true);
    }
  });
  d3.select("#time2").on("change",function(d){
    if ($('#time2').val() == '75' || $('#time2').val() == '270') {
      $('#tex2').removeAttr("disabled");
    } else {
      $('#tex2').attr("disabled",true);
    }
  });
  d3.select("#time3").on("change",function(d){
    if ($('#time3').val() == '75' || $('#time3').val() == '270') {
      $('#tex3').removeAttr("disabled");
    } else {
      $('#tex3').attr("disabled",true);
    }
  });
  d3.select("#time4").on("change",function(d){
    if ($('#time4').val() == '75' || $('#time4').val() == '270') {
      $('#tex4').removeAttr("disabled");
    } else {
      $('#tex4').attr("disabled",true);
    }
  });




},200);




 $('#viz').resizable();
