google.charts.load('current', {packages: ['corechart', 'line']});
google.charts.setOnLoadCallback(drawCurveTypes);

function drawCurveTypes() {
      var data = new google.visualization.DataTable();
      data.addColumn('number', 'X');
      //data.addColumn('number', 'SpaceTimeBlocking');
      data.addColumn('number', 'SharedMemory');

      data.addRows([
[64,108.41396],
[96,89.01120],
[128,95.11117],
[160,113.37702],
[192,101.13689],
[224,154.31091],
[256,186.73097],
[288,218.92052],
[320,232.28406],
[352,295.31876],
[384,304.94522],
[416,385.76855],
[448,570.88287],
[480,701.02271],
[512,768.65991],
[544,881.91882],
[576,979.11212],
[608,1082.10193],
[640,1188.77576],
[672,1316.50024],
[704,1436.11035],
[736,1532.38489],
[768,1576.36401]
      ]);

      var options = {
      	width: 1200,
        height: 200,
        chartArea: {  width: "60%", height: "60%" },
        
        hAxis: {
          title: 'Model Size'
        },
        vAxis: {
          title: 'Time'
        },
        series: {
          1: {curveType: 'function'}
        }
      };

      var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
      chart.draw(data, options);
    }