<template>
<v-main id="main">
    <v-container v-if="pending" class="text-center">
        <v-progress-circular
        indeterminate
        color="primary"
        ></v-progress-circular>
    </v-container>
    <v-container v-else-if="fetchError" class="text-center">
        <p>An error occurred...</p>
    </v-container>
    <v-container v-else class="mt-6">
        <v-row>
            <v-col
                v-for="building in buildings"
                :key="building.id"
                cols="4"
                >
                    <v-card
                    class="mx-auto"
                    max-width="344"
                    color="white"
                    outlined
                    >
                        <v-list-item three-line>
                        <v-list-item-content>
                            <div class="text-overline mb-4">
                            OVERLINE
                            </div>
                            <v-list-item-title class="text-h5 mb-1">
                            {{ building.name }}
                            </v-list-item-title>
                            <v-list-item-subtitle>Greyhound divisely hello coldly fonwderfully</v-list-item-subtitle>
                        </v-list-item-content>

                        <v-list-item-avatar
                            tile
                            size="80"
                            color="grey"
                        ></v-list-item-avatar>
                        </v-list-item>

                        <v-card-actions>
                        <!-- :href="'/rooms/' + room.id + '/'"    :href="`/rooms/${room.id}/`" -->
                        <v-btn  @click.stop="goToBuilding(building.id)"
                            outlined
                            rounded
                            text
                            class="mx-auto my-3 d-block"
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

<script setup>
import { ref, watch } from 'vue';


const pending = ref(true);
const fetchError = ref(false);
const buildings = ref([]);
const config = useRuntimeConfig();

if (process.client) {
    setTimeout(() => {
    console.log("Running async code!");
    $fetch(config.public.apiUrl + '/buildings')
        .then(response => {
            console.log("f1")
            buildings.value = response;
            pending.value = false;
            //return response;
            //this.$foreceUpdate();
        }).catch(error => {
            fetchError.value = true;
            console.log("fe");
        });
    }, 200);
}




function goToBuilding(building_id) {
  console.log("goToBuilding fn");
  console.log(event);
  if (process.client) {
    //window.setTimeout(() =>  { navigateTo("/rooms/" + room_id) }, 3000);
    navigateTo("/admin/building-" + building_id);
  }
}

</script>

<style>
#main {
    background: #f7f7f7;
}
</style>