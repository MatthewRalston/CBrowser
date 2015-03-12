$(document).ready(function(){
  // Initialize slider
  $('#rangeSlider').noUiSlider({
    start: [175000,176000],
    margin: 300,
    connect: true,
    behaviour: 'drag-fixed',
    range: {'min': 0,
	    'max': 192000
    },
    limit: 50000,
    step: 1
  },true);
  // Create links
  $('#first-base').remove();
  var slider = $( '#rangeSlider' );
  slider.Link('lower').to($( '#start' ));
  slider.Link('upper').to($( '#end' ));
  // Adjusts range to chromosome
  var chr;
  d3.select('#chrSelect').on('change',function(d){
    chr=this;
    if (chr.value === "Chrom") {
      d3.select("#start").attr("value",'{:min=>"0",:max=>"3940880",:step=>"1"}');
      d3.select("#end").attr("value",'{:min=>"0",:max=>"3940880",:step=>"1"}');
      $('#rangeSlider').noUiSlider({range: {'min': 0,'max': 3940880}},true);
    } else {
      d3.select("#start").attr("value",'{:min=>"0",:max=>"192000",:step=>"1"}');
      d3.select("#end").attr("value",'{:min=>"0",:max=>"192000",:step=>"1"}');
      $('#rangeSlider').noUiSlider({range: {'min': 0,'max': 192000}},true)
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
