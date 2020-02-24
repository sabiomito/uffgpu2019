google.charts.load('current', {packages: ['corechart', 'line']});
google.charts.setOnLoadCallback(drawCurveTypes);

function drawCurveTypes() {
      var data = new google.visualization.DataTable();
      data.addColumn('number', 'X');
      data.addColumn('number', 'SpaceTimeBlocking');
      data.addColumn('number', 'SharedMemory');

      data.addRows([
[64,129.17760,108.41396],
[96,109.63456,89.01120],
[128,123.89990,95.11117],
[160,157.87997,113.37702],
[192,137.98970,101.13689],
[224,203.62314,154.31091],
[256,260.56696,186.73097],
[288,305.27335,218.92052],
[320,319.66443,232.28406],
[352,414.40485,295.31876],
[384,440.51910,304.94522],
[416,534.10492,385.76855],
[448,695.51990,570.88287],
[480,854.89484,701.02271],
[512,941.42102,768.65991],
[544,1064.33423,881.91882],
[576,1199.87842,979.11212],
[608,1322.36169,1082.10193],
[640,1459.24243,1188.77576],
[672,1615.91309,1316.50024],
[704,1771.44153,1436.11035],
[736,1891.16492,1532.38489],
[768,1998.08093,1576.36401]
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