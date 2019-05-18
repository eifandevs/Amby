<template>
  <div class="base">
    <div class="content">
      <div>
        <div class="message user">
          <div class="data">
            <span>{{ this.msg }}</span>
          </div>
        </div>
      </div>
      <div class="mt10">
        <div class="message user">
          <div class="data">
            <span>{{ this.counter }}</span>
          </div>
        </div>
      </div>
      <div class="mt10 tar">
        <div class="message system">
          <div class="data">
            <span>{{ this.counter }}</span>
          </div>
        </div>
      </div>
      <div class="mt10">
        <div class="message user">
          <div class="data">
            <span>{{ this.counter }}</span>
          </div>
        </div>
      </div>
      <div class="mt10">
        <div class="message user">
          <div class="data">
            <span>{{ this.counter }}</span>
          </div>
        </div>
      </div>
      <div class="mt10">
        <div class="message user">
          <div class="data">
            <span>{{ this.counter }}</span>
          </div>
        </div>
      </div>
      <div class="mt10">
        <div class="message user">
          <div class="data">
            <span>{{ this.counter }}</span>
          </div>
        </div>
      </div>
      <div class="send-message">
        <div class="wrapper">
          <textarea id="comment" placeholder="ご意見・ご感想をご記入ください"></textarea>
          <button v-on:click="send">送信</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator';

@Component
export default class Report extends Vue {
  @Prop() private msg!: string;
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.base {
  display: block;
  margin: 0px;
}

.mt10 {
  margin-top: 10px;
}
.tal {
  text-align: left;
}
.tar {
  text-align: right;
}

.content {
  margin: 10px;
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

.send-message {
  position: fixed;
  left: 10px;
  width: calc(100% - 20px);
  bottom: 10px;
}
.wrapper {
  display: flex;
}
.wrapper textarea {
  background: white;
  flex: 1 1 auto;
}

</style>