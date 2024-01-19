<template>
<!--       v-if="drawerStore.showDrawer" floating? hide-overlay? -->
<v-navigation-drawer
      absolute
      v-model="showDrawer"
      temporary
    >
      <v-list
        nav
        dense
      >
        <v-list-group
          active-class="deep-purple--text text--accent-4"
        >
          <v-list-item link>
          <!--
          <v-btn
            @click="manualToggle()"
            elevation="2"
            absolute
            large
            right
          ></v-btn>
          -->
            <v-list-item-title>Foo</v-list-item-title>
          </v-list-item>

          <v-list-item link>
            <v-list-item-title>Bar</v-list-item-title>
          </v-list-item>

          <v-list-item link>
            <v-list-item-title>Fizz</v-list-item-title>
          </v-list-item>

          <v-list-item link>
            <v-list-item-title>Buzz</v-list-item-title>
          </v-list-item>
        </v-list-group>
      </v-list>
    </v-navigation-drawer>
</template>


<script setup lang="ts">
import { reactive, computed, watch, ref } from 'vue';
import { useDrawerStore } from "~/store/drawer";

const drawerStore = useDrawerStore();

//let showDrawer = reactive(true);
let showDrawer = ref(false);



function manualToggle(): void {
  //manualDrawer.value = manualDrawer.value ? false : true;
  console.group("----");
  //console.log("rd: ")
  //console.log(rd)
  console.log("showDrawer: ")
  console.log(showDrawer)
  console.log("userStore drawer: ")
  console.log(drawerStore.showDrawer)
  console.groupEnd();
}


drawerStore.$onAction(({name: toggleDrawer}) => {
  console.log(showDrawer);
  showDrawer.value = showDrawer.value ? false : true;
  }, true);

</script>