google.charts.load('current', {packages: ['corechart', 'line']});
google.charts.setOnLoadCallback(drawCurveTypes);

function drawCurveTypes() {
      var data = new google.visualization.DataTable();
      data.addColumn('number', 'X');
      data.addColumn('number', 'SpaceTimeBlocking');
      data.addColumn('number', 'SharedMemory');

      data.addRows([
[1,73.15047,62.53318],
[2,54.99187,62.53318],
[3,49.32710,62.53318],
[4,46.89817,62.53318],
[5,45.84448,62.53318],
[6,45.38982,62.53318],
[7,45.90285,62.53318],
[8,47.10298,62.53318],
[9,48.16998,62.53318],
[10,49.14688,62.53318],
[11,50.05824,62.53318],
[12,51.29523,62.53318],
[13,52.98893,62.53318],
[14,54.53619,62.53318],
[15,56.00359,62.53318],
[16,57.50682,62.53318]
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