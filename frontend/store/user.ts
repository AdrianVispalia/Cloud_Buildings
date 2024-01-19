import { defineStore } from 'pinia'


enum UserRole {
  CUSTOMER = 0,
  ADMIN = 1
}


interface User {
  username: string;
  token: string;
  admin: boolean;
}


export const useUserStore = defineStore({
  id: "user",
  
  state: (): User => ({
    username: "",
    token: "",
    admin: false,
  }),

  getters: {
    to_string(): string {
      return `<username: ${this.username}, token: ${this.token}, isAdmin?: ${this.admin}>`;
    }
  },

  actions: {
    isLoggedIn(): boolean {
      return this.token.length !== 0;
    },
    isAdmin(): boolean {
      return this.admin;
    },
    setUsername(new_username: string): void {
      this.username = new_username
    },
    setToken(new_token: string): void {
      this.token = new_token;
    },
    logout(): void {
      this.username = "";
      this.token = "";
      this.admin = false;
    },

    async login(username: string, password: string): Promise<boolean> {
			console.log("Login try with: " + username + " " + password);
      const config = useRuntimeConfig()
      const url = config.public.apiUrl + '/token';
      let formBody = encodeURIComponent("username") + "=" + encodeURIComponent(username)
                  + "&" + encodeURIComponent("password") + "=" + encodeURIComponent(password);
      window.console.log(formBody);

      const request = {
          method: 'POST',
          headers: {
              'Content-type': 'application/x-www-form-urlencoded',
              'Accept': 'application/x-www-form-urlencoded'
          },
          body: formBody,
      };

      return fetch(url, request).then((response) => {
        console.log(response);
        if (response.ok === false) {
          return false;
        }
        return response.json();
      })
      .then((data) => {
        if (data === false) { return false; }

        console.log(data);
        this.username = username;
        this.token = data;
        this.getUserInfo();
        return true;
      }).catch(() => { return false; })
		},

    getUserInfo(): void {
      console.log("Getting user basic info");

      if (this.token.length === 0) return;
      const config = useRuntimeConfig()
      const url = config.public.apiUrl + '/users/me';
      console.log("URL: " + url);
      const request = {
          method: 'GET',
          headers: {
              'Content-type': 'application/json',
              'Authorization': 'Bearer ' + this.token,
          }
      };

      fetch(url, request).then((response) => {
        console.log(response);
        return response.json();
      })
      .then((data) => {
        console.log("getUserInfo data");
        console.log(data);
        this.admin = data.role === UserRole.ADMIN;
      })
    },
  }
});
