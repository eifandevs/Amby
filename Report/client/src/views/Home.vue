<template>
  <div class="home">
    <Report msg="Welcome to Your Vue.js + TypeScript App"/>
  </div>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';
import Report from '@/components/Report.vue'; // @ is an alias to /src

@Component({
  components: {
    Report,
  },
})
export default class Home extends Vue {}
</script>
