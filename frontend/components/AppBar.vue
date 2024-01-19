<template>
  <v-app-bar>
    <v-toolbar
      color="secondary"
      class="px-8 py-4"
      style="width:inherit;"
      prominent
      dark
      src="https://cdn.vuetifyjs.com/images/backgrounds/vbanner.jpg"
    >
      <!--
      <v-app-bar-nav-icon @click="toggleDrawer()"></v-app-bar-nav-icon>
      -->

      <v-toolbar-title>Room Advisor</v-toolbar-title>

      <v-spacer></v-spacer>


      <v-btn flat class="px-2 mx-3" to="/" nuxt> Home </v-btn>
      <v-btn flat class="px-2 mx-3" to="/search" nuxt> Search </v-btn>

      <v-btn flat v-if="userStore.isAdmin()" class="px-2 mx-3" to="/admin" nuxt> Admin </v-btn>

      <div v-if="userStore.isLoggedIn()" class="px-2">
        <p>{{ userStore.username }}</p>
      </div>

      <v-btn flat v-if="userStore.isLoggedIn()" class="px-2 mx-3" icon @click="logout">
        <v-icon>mdi-export</v-icon>
      </v-btn>

      <v-btn flat v-else="userStore.isLoggedIn()" class="px-2 mx-3" to="/login" nuxt> Log In </v-btn>
    </v-toolbar>
  </v-app-bar>
</template>

<script setup lang="ts">
import { useUserStore } from "~/store/user";
import { useDrawerStore } from "~/store/drawer";

const userStore = useUserStore();
const drawerStore = useDrawerStore();

function toggleDrawer() {
  drawerStore.toggleDrawer();
}

//const drawer = ref(false);
//const group = ref(null);

/*
function changeDrawer() {
  drawer.value = drawer.value ? false : true;
  console.log("Change drawer: " + drawer.value);
  console.log("Group: " + group.value);
}
// */

function logout () {
  userStore.logout();
}

function out() {
  console.log("out fn");
  if (process.client) {
    window.setTimeout(() =>  { navigateTo("/") }, 200);
  }
}
</script>
