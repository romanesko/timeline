import "./app.pcss";
import App from "./App.svelte";


WebFont.load({
  google: {
    families: ['Rubik']
  },
  active: function () {
    setTimeout(() => {
      new App({
        target: document.getElementById("app"),
      });
    }, 100)
  }
});

// export default app;
