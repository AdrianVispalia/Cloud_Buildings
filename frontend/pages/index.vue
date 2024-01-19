<template>
    <v-main id="main">
    <v-container id="title-container" class="mx-auto mt-12 d-block p-3" align="center" justify="center">
            <h1 id="title" class="mx-auto d-block">
                Room Advisor
            </h1>
    </v-container>
    <v-btn id="button" class="mt-12 mx-auto my-3 d-block p-5" color="accent" elevation="2"
        outlined to="/search" justify="center" nuxt> Start the search </v-btn>
    </v-main>
</template>

<script setup lang="ts">
const config = useRuntimeConfig();
console.log("Test");
console.log(config.public);
console.log(config.public.apiUrl);
if (process.client) {
    console.log("Test");
    console.log(config.public);
    console.log(config.public.apiUrl);
}
</script>

<style>
#main {
    /*background-color: #0ea7932a;*/
}

#title-container {
    border-radius: 25px;
    background-color: #0ea79323;
    box-shadow: inset 0px 0px 4px 4px #0ea7937a;
    width: fit-content;
}

#title {
    font-size: 7vw;
    margin-left: auto;
    margin-right: auto;
    color: #0ea792b8;
    text-shadow: 0px 4px 20px #00000075;
}

#subtitle {
    font-size: 2vw;
    margin-left: auto;
    margin-right: auto;
}

#button {
    background-color: #0cf08688;
    font-size: 2vw;
    width: fit-content;
    padding: .5em .7em 1.5em;
    font-weight: bold;
}
</style>
