google.charts.load('current', {packages: ['corechart', 'line']});
google.charts.setOnLoadCallback(drawCurveTypes);

function drawCurveTypes() {
      var data = new google.visualization.DataTable();
      data.addColumn('number', 'X');
      data.addColumn('number', 'SpaceTimeBlocking');
      data.addColumn('number', 'SharedMemory');

      data.addRows([
[1,2020.27380,1576.36401],
[2,1374.22351,1576.36401],
[3,1280.81531,1576.36401],
[4,1255.66321,1576.36401],
[5,1264.58386,1576.36401],
[6,1288.68298,1576.36401],
[7,1328.83606,1576.36401],
[8,1371.81787,1576.36401],
[9,1413.29858,1576.36401],
[10,1463.86353,1576.36401],
[11,1519.91272,1576.36401],
[12,1579.24939,1576.36401],
[13,1636.50732,1576.36401],
[14,1702.82043,1576.36401]
      ]);

      var options = {
      	width: 1200,
        height: 200,
        chartArea: {  width: "60%", height: "60%" },
        
        hAxis: {
          title: 'Time steps'
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