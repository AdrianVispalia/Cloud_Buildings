import { defineStore } from 'pinia'

interface Drawer {
  showDrawer: boolean;
  optionSelected: string;
}

export const useDrawerStore = defineStore({
  id: "drawer",
  state: (): Drawer => ({
    showDrawer: true,
    optionSelected: "",
  }),
  getters: {
    to_string(): string {
      return `<showDrawer: ${this.showDrawer}, optionSelected: ${this.optionSelected}>`;
    }
  },
  actions: {
    toggleDrawer(): void {
        this.showDrawer = this.showDrawer ? false : true;
        console.log("New showDrawer: " + this.showDrawer);
    },
    setOptionSelected(new_option: string) {
        this.optionSelected = new_option;
    }
  }
});
