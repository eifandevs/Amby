<template>
  <div id="app">
    <Report msg="Welcome to Your Vue.js App"/>
  </div>
</template>

<script>
import Report from './components/Report.vue'

export default {
  name: 'app',
  components: {
    Report
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
</style>
