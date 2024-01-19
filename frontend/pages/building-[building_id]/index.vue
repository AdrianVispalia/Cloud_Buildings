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
    <v-container class="mt-16">
      <v-row class="mt-8">
        <v-col
          v-for="n in room_num"
          :key="n"
          :id="'a-' + n"
          cols="4"
        >
          <v-card height="282" class="pa-4">
            <v-list-item>
                <v-list-item-title class="text-h5 mb-1 pa-1">
                {{ getRoomName(n - 1) }}
                </v-list-item-title>
            </v-list-item>
            <canvas :id="'myChart-' + (n - 1)"></canvas>
  
            <v-card-actions>
              <!-- :href="'/rooms/' + room.id + '/'"    :href="`/rooms/${room.id}/`" -->
              <v-btn  @click.stop="goToRoom(n - 1)"
                  outlined
                  rounded
                  text
                  class="mx-auto my-1 d-block"
              >
              More details
              </v-btn>
            </v-card-actions>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </v-main>
  </template>
  
  <script setup lang="ts">
  import { ref } from 'vue';
  import { useUserStore } from "~/store/user";
  //import VListItemContent from '@/components/VListItemContent.vue';
  
  
  const userStore = useUserStore();
  const pending = ref(true);
  const fetchError = ref(false);
  const room_num = ref(0);
  const rooms = ref([]);
  
  const route = useRoute();
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
  
  
  function createChart(canvas_id, data) {
    console.log("canvas_id:")
    console.log(canvas_id)
    console.log(config.apiUrl)
    const dates = data.map((m) => m.timestamp);
    const temperature = data.map((m) => { return {t: m.timestamp, y: m.temperature }});
    const humidity = data.map((m) => { return {t: m.timestamp, y: m.humidity }});
    const light = data.map((m) => { return {t: m.timestamp, y: m.light }});
    const noise_level = data.map((m) => { return {t: m.timestamp, y: m.noise_level }});
  
    new Chart(canvas_id, {
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
  
  let get_rooms = function(building_id) {
    console.log("get_rooms was updated")
    //'http://localhost:8000/api/rooms/' + route.params.id + '//'
    let url = config.public.apiUrl + '/buildings/' + building_id + '/rooms';
    const request = {
      method: 'GET',
      headers: {
          'Content-type': 'application/json',
          'authorization': 'Bearer ' + userStore.token,
      },
    };
    $fetch(url, request)
      .then((response) => {
        console.log("got an answer")
        console.log(response)
        console.log("f1")
        pending.value = false;
        rooms.value = response;
        room_num.value = response.length;
  
        response.map((room, index) => {
          console.log("room: " + room.id + " index: " + index);
          draw_last_measurements(room, "myChart-" + index);
        });
        //return response;
        //this.$foreceUpdate();
    }).catch(error => {
        fetchError.value = true;
        console.log("fe");
        console.log(error);
    }).catch(error => {console.log(error)});
  };
  
  let draw_last_measurements = function(room, canvas_id) {
    //'http://localhost:8000/api/rooms/' + route.params.id + '//'
    // || userStore.isAdmin == false
    if (userStore.isLoggedIn() == false ) {
      fetchError.value = true;
      return;
    }
  
    console.log("Executing function get last measures")
    console.log(room)
  
    //'api/rooms/' + route.params.id + '//'
    let url = config.public.apiUrl + '/buildings/' + building_id + '/rooms/' + room.id + '/last_room_measurements';
    const request = {
      method: 'GET',
      headers: {
          'Content-type': 'application/json',
          'authorization': 'Bearer ' + userStore.token,
      },
    };
    console.log("about to fetch...")
    fetch(url, request).then((response) => {
      console.log("got an answer")
      return response.json();
    }).then(data => {
      console.log("FINALLY!! THE DATA!")
      console.log(data)
      pending.value = false;
  
      createChart(canvas_id, data);
      //setTimeout(() => { createChart("myChart", values); }, 1500);
      
      console.log("Values inserted??")
    }).catch(error => {
      fetchError.value = true;
      console.log("fetch Error");
      console.log(error);
    });
  
    console.log("End of client script");
  };
  
  
  if (process.client) {
    setTimeout(() => {
      get_rooms(building_id);
      
      console.log()
  
    }, 1000);
  }
  
  function goToRoom(room_index) {
    console.log("room_index: " + room_index);
    console.log("rooms:")
    console.log(rooms.value);
    let room_id = rooms.value[room_index].id;
    console.log("goToRoom fn");
    console.log(event);
    if (process.client) {
      //window.setTimeout(() =>  { navigateTo("/rooms/" + room_id) }, 3000);
      navigateTo("/building-" + route.params.building_id + '/room-' + room_id);
    }
  }
  
  function getRoomName(room_index) {
    if (rooms.value.length < 1) return "";
    else return rooms.value[room_index].name;
  }
  
  
  </script>
  