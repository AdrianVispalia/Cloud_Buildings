<template>
<v-main style="background: #f7f7f7;">
  <v-container v-if="pending" class="text-center">
      <v-progress-circular
      indeterminate
      color="primary"
      ></v-progress-circular>
  </v-container>
  <v-container v-else-if="fetchError" class="text-center">
      <p>An error occurred...</p>
  </v-container>
  <v-container class="my-auto mx-auto pt-4">
    <h2 class="mx-auto my-6">{{ roomName }}</h2>
    <canvas id="myChart"></canvas>
  </v-container>
</v-main>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useUserStore } from "~/store/user";


const userStore = useUserStore();
const pending = ref(true);
const fetchError = ref(false);

const roomName = ref("Room name");

const route = useRoute();
const room_id = route.params.room_id;
const building_id = route.params.building_id;
const config = useRuntimeConfig();

useHead({
  script: [{
    src: 'https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.js',
    body: true
  },
  {
    src: "https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.1/moment.min.js",
    body: true
  }]
});

function createChart(id, data) {
  const dates = data.map((m) => m.timestamp);
  const temperature = data.map((m) => { return {t: m.timestamp, y: m.temperature }});
  const humidity = data.map((m) => { return {t: m.timestamp, y: m.humidity }});
  const light = data.map((m) => { return {t: m.timestamp, y: m.light }});
  const noise_level = data.map((m) => { return {t: m.timestamp, y: m.noise_level }});

  new Chart(id, {
    type: 'line',
      options: {
        scales: {
          xAxes: [{
            type: 'time',
          }]
        }
      },
    data: {
      datasets: [
      {
        label: 'Temperature',
        data: temperature,
        backgroundColor: 'rgba(255, 99, 132, 0.2)' ,
        borderColor: 'rgba(255, 99, 132, 1)',
        borderWidth: 1,
        lineTension: 0,
        cubicInterpolationMode: 'linear'
      },
      {
        label: 'Humidity',
        data: humidity,
        backgroundColor: 'rgba(255, 206, 86, 0.2)' ,
        borderColor: 'rgba(255, 206, 86, 1)',
        borderWidth: 1,
        lineTension: 0,
        cubicInterpolationMode: 'linear'
      },
      {
        label: 'Light',
        data: light,
        backgroundColor: 'rgba(25, 206, 86, 0.2)' ,
        borderColor: 'rgba(25, 206, 86, 1)',
        borderWidth: 1,
        lineTension: 0,
        cubicInterpolationMode: 'linear'
      },
      {
        label: 'Noise level',
        data: noise_level,
        backgroundColor: 'rgba(255,110, 32, 0.2)' ,
        borderColor: 'rgba(255, 120, 32, 1)',
        borderWidth: 1,
        lineTension: 0,
        cubicInterpolationMode: 'linear'
      },
      ]
    }
  });
}

if (process.client) {
  console.log("Starting client script execution")

  setTimeout(() => {
    if (userStore.isLoggedIn() == false) {
      fetchError.value = true;
      return;
    }

    console.log("Executing function get last measures")
    //'api/rooms/' + route.params.id + '//'
    const request = {
        method: 'GET',
        headers: {
            'Content-type': 'application/json',
            'authorization': 'Bearer ' + userStore.token,
        },
    };

    let measures_url = config.public.apiUrl + '/buildings/' + building_id + '/rooms/' + room_id + '/last_room_measurements';
    console.log("about to fetch...")
    fetch(measures_url, request).then((response) => {
      console.log("got an answer")
      return response.json();
    }).then(data => {
          console.log("FINALLY!! THE DATA!, url: " + measures_url)
          console.log(data)
          pending.value = false;

          createChart("myChart", data);
          //setTimeout(() => { createChart("myChart", values); }, 1500);
          
          console.log("Values inserted??")
      }).catch(error => {
          fetchError.value = true;
          console.log("fetch Error");
          console.log(error);
    });

    let room_url = config.public.apiUrl + '/buildings/' + building_id + '/rooms/' + room_id;
    $fetch(room_url, request)
        .then(response => {
            console.log("f1r, url: " + room_url)
            console.log(response);
            roomName.value = response.name;
            //return response;
            //this.$foreceUpdate();
        }).catch(error => {
            console.log("fer");
        });

    console.log("End of client script");

  }, 1500);
}



</script>

<style>
h2 {
  font-size: 2vw;
  text-align: center;
  color: #000000b3;
}
</style>