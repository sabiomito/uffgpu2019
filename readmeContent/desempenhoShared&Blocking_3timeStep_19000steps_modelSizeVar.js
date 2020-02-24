google.charts.load('current', {packages: ['corechart', 'line']});
google.charts.setOnLoadCallback(drawCurveTypes);

function drawCurveTypes() {
      var data = new google.visualization.DataTable();
      data.addColumn('number', 'X');
      data.addColumn('number', 'SpaceTimeBlocking');
      data.addColumn('number', 'SharedMemory');

      data.addRows([
[64,67.17338,108.41396],
[96,73.43821,89.01120],
[128,69.72105,95.11117],
[160,102.32105,113.37702],
[192,95.80384,101.13689],
[224,151.29449,154.31091],
[256,192.71878,186.73097],
[288,233.37511,218.92052],
[320,244.33002,232.28406],
[352,320.36841,295.31876],
[384,335.69699,304.94522],
[416,416.25119,385.76855],
[448,482.25211,570.88287],
[480,573.45233,701.02271],
[512,621.53406,768.65991],
[544,768.02942,881.91882],
[576,861.47559,979.11212],
[608,951.82483,1082.10193],
[640,1020.84338,1188.77576],
[672,1149.16162,1316.50024],
[704,1252.32043,1436.11035],
[736,1353.03125,1532.38489],
[768,1271.58630,1576.36401]
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