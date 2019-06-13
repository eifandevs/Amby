<template>
  <div class="tar">
    <div class="message system">
      <div class="data">
        <span class="line-break">{{ this.message }}</span>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator';

@Component
export default class Message extends Vue {
  @Prop() private message!: string;
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.tar {
  text-align: right;
}

.message {
  display: inline-block;
  color: #333;
  background: #fff;
  border: 2px solid #5F4B8B;
  line-height: 1.3em;
}
.message.user {
  border-radius: 30px 30px 30px 0px;
}
.message.system {
  border-radius: 30px 30px 0px 30px;
}
.data {
  margin: 10px;
}

.line-break {
  word-break: break-all;
}
</style>