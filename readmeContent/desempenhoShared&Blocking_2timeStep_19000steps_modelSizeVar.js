google.charts.load('current', {packages: ['corechart', 'line']});
google.charts.setOnLoadCallback(drawCurveTypes);

function drawCurveTypes() {
      var data = new google.visualization.DataTable();
      data.addColumn('number', 'X');
      data.addColumn('number', 'SpaceTimeBlocking');
      data.addColumn('number', 'SharedMemory');

      data.addRows([
[64,72.77876,108.41396],
[96,68.43904,89.01120],
[128,95.85869,95.11117],
[160,131.51450,113.37702],
[192,113.76279,101.13689],
[224,158.95590,154.31091],
[256,202.46518,186.73097],
[288,244.77020,218.92052],
[320,255.08665,232.28406],
[352,334.95300,295.31876],
[384,352.39133,304.94522],
[416,435.59821,385.76855],
[448,515.49200,570.88287],
[480,614.31763,701.02271],
[512,668.59668,768.65991],
[544,812.55713,881.91882],
[576,909.72180,979.11212],
[608,1002.84662,1082.10193],
[640,1091.39026,1188.77576],
[672,1209.08679,1316.50024],
[704,1319.01038,1436.11035],
[736,1424.51331,1532.38489],
[768,1372.17993,1576.36401]
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