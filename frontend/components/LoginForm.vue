<template>
<form @submit.prevent class="form-class px-6 py-1 mt-1 mb-2">
  <!--
  <p>{{ JSON.stringify(user) }} -- {{ userStore.username }}
    -- {{ userStore.token }} -- {{ Object.getOwnPropertyNames($router) }}</p>
  -->
	<div class="field-div form-group my-2 text-h6">
		<label for="InputUsername" class="field-label form-label d-block">Username: </label>
    <input type="text" id="InputUsername" v-model="user.username"
        placeholder="Your username" autocomplete="username" required />
	</div>
	<div class="field-div form-group my-2 text-h6">
		<label for="InputPassword" class="field-label form-label d-block">Password: </label>
     <input type="password" id="InputPassword" v-model="user.password" 
        placeholder="Your password" autocomplete="current-password" required />
	</div>
  <v-btn @click="login" type="submit" class="mx-auto my-3 d-block" color="accent" elevation="2" outlined>Log in</v-btn>
  <!--
  <button @click="login" type="submit" class="disabled-main-button main-button">Log in</button>
  -->
  <p class="register-p">Not a member?
		<NuxtLink to="../register" class="register-link">  Register</NuxtLink>
	</p>
</form>

<!--
<form @submit.prevent>
  <button @click="out" type="submit" class="disabled-main-button main-button">Out</button>
</form>
-->
</template>

<script setup lang="ts">
import { ref, watch } from 'vue';
import { useUserStore } from "~/store/user";


const userStore = useUserStore();
const router = useRouter();

const user = ref({
  username: "",
  password: "",
});

function login(): void {
  console.log("Client or not?")
  console.log(process.client);
  userStore.login(
      user.value.username,
      user.value.password
    ).then((event) => {
        console.log("Form filled. Event:");
        console.log(event);
      if (event) {
        console.log("getting out!!!");
        out();
      } else {
        loginFailed();
      }
    });
};


function loginFailed() {
  console.log("loginFailed fn");
  if (process.client) {
    window.alert("Invalid credentials!");
  }
}

function out() {
  console.log("out fn");
  if (process.client) {
    window.setTimeout(() =>  { navigateTo("/") }, 1);
  }
}
</script>
