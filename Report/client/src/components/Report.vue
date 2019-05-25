<template>
  <div class="base">
    <div class="content">
      <div v-for="(object, index) in this.messages" :key="index">
        <div v-if="object.isUserMessage">
          <UserMessage class="mt10" v-bind:message="object.msg"/>
        </div>
        <div v-else>
          <SystemMessage class="mt10" v-bind:message="object.msg"/>
        </div>
      </div>
      <div class="send-message">
        <div class="wrapper">
          <textarea id="comment" placeholder="ご意見・ご感想をご記入ください"></textarea>
          <button @click="send">送信</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator';
import UserMessage from '@/components/UserMessage.vue';
import SystemMessage from '@/components/SystemMessage.vue';

@Component({
  components: {
    UserMessage,
    SystemMessage,
  },
})

export default class Report extends Vue {
  private messages: Array<{msg: string, isUserMessage: boolean}> = [
                                                                    {msg: 'testtesttesttest', isUserMessage: true},
                                                                    {msg: 'testtesttesttest', isUserMessage: false},
                                                                    {msg: 'testtesttesttest', isUserMessage: true},
                                                                   ];

  private send() {
    alert(this.messages[0].isUserMessage);
  }
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