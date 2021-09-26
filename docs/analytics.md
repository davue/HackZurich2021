---
layout: default
title: Analyse
---

<div class="row">
  <div class="col-sm">
    <div class="card text-white bg-secondary mb-3">
      <div class="card-header">Datensätze</div>
      <div class="card-body">
        <p class="card-text">Die Datensätze der letzten <b>7</b> Tagen beinhalten durchschnittlich <b>50'134</b> RSSI Werte.</p>
      </div>
    </div>
  </div>
  <div class="col-sm">
    <div class="card text-white bg-secondary mb-3">
      <div class="card-header">RSSI Werte</div>
      <div class="card-body">
        <p class="card-text">Die RSSI der letzten <b>7</b> Tage sind im Schnitt bei <b>2.23</b> Volt, tendez leicht steigend.</p>
      </div>
    </div>
  </div>
  <div class="col-sm">
    <div class="card text-white bg-secondary mb-3">
      <div class="card-header">Anteil gültiger Telegramme</div>
      <div class="card-body">
        <p class="card-text">In den letzten <b>7</b> Tagen wurden im Schnitt <b>98%</b> der Telegramme korrekt übermittelt.</p>
      </div>
    </div>
  </div>
</div>

<canvas class="my-4 w-100" id="rssiCount" width="900" height="380"></canvas>
<canvas class="my-4 w-100" id="rssiValue" width="900" height="380"></canvas>
<canvas class="my-4 w-100" id="validTelegramShare" width="900" height="380"></canvas>

<script>
  (function () {
    // Graphs
      let rssiCountCtx = document.getElementById('rssiCount');
      let rssiValueCtx = document.getElementById('rssiValue');
      let validTelegramShareCtx = document.getElementById('validTelegramShare');

      new Chart(rssiCountCtx, {
        type: 'line',
        data: {
          labels: [
            '20.09.2021',
            '21.09.2021',
            '22.09.2021',
            '23.09.2021',
            '24.09.2021',
            '25.09.2021',
            '26.09.2021'
          ],
          datasets: [{
            label: 'Anzahl RSSI Werte',
            data: [
              50613,
              48583,
              51598,
              50444,
              50432,
              49248,
              50186
            ],
            lineTension: 0,
            backgroundColor: 'transparent',
            borderColor: '#007bff',
            borderWidth: 4,
            pointBackgroundColor: '#007bff'
          }]
        },
        options: {
          scales: {
            yAxes: [{
              ticks: {
                beginAtZero: false
              }
            }]
          },
          legend: {
            display: true
          }
        }
      });

      new Chart(rssiValueCtx, {
        type: 'line',
        data: {
          labels: [
            '20.09.2021',
            '21.09.2021',
            '22.09.2021',
            '23.09.2021',
            '24.09.2021',
            '25.09.2021',
            '26.09.2021'
          ],
          datasets: [{
            label: 'Durchschnittlicher RSSI Wert',
            data: [
              2.41,
              2.01,
              2.11,
              2.11,
              2.32,
              2.14,
              2.22
            ],
            lineTension: 0,
            backgroundColor: 'transparent',
            borderColor: 'red',
            borderWidth: 4,
            pointBackgroundColor: 'red'
          }]
        },
        options: {
          scales: {
            yAxes: [{
              ticks: {
                beginAtZero: false
              }
            }]
          },
          legend: {
            display: true
          }
        }
      });

      new Chart(validTelegramShareCtx, {
        type: 'line',
        data: {
          labels: [
            '20.09.2021',
            '21.09.2021',
            '22.09.2021',
            '23.09.2021',
            '24.09.2021',
            '25.09.2021',
            '26.09.2021'
          ],
          datasets: [{
            label: 'Anteil gültiger Telegramme',
            data: [
              99.5,
              97.3,
              98.0,
              99.1,
              99.2,
              95.6,
              98.2
            ],
            lineTension: 0,
            backgroundColor: 'transparent',
            borderColor: 'green',
            borderWidth: 4,
            pointBackgroundColor: 'green'
          }]
        },
        options: {
          scales: {
            yAxes: [{
              ticks: {
                beginAtZero: false
              }
            }]
          },
          legend: {
            display: true
          }
        }
      });
  })();
</script>
