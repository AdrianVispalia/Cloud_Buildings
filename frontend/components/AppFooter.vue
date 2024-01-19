<template>
  <div>
  <v-footer
    color="secondary"
    app
    bottom
    fixed
    padless
    max-height=200
  >
    <v-row
      justify="center"
      no-gutters
    >
    <!--
      <v-btn
        v-for="link in links"
        :key="link"
        color="white"
        text
        rounded
        class="my-2"
      >
        {{ link }}
      </v-btn>
    -->
      <v-col
        class="py-4 text-center white--text"
        cols="12"
      >
        {{ new Date().getFullYear() }} — <strong>Cloud Buildings</strong>
      </v-col>
    </v-row>
  </v-footer>
  </div>
</template>

<script>
  export default {
    data: () => ({
      links: [
        'Home',
        'About Us',
        'Team',
        'Services',
        'Blog',
        'Contact Us',
      ],
    }),
  }
</script>