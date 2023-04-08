import Navbar from './components/Navbar';
import Chat from './components/Chat';
import { ConversationProvider } from './contexts/ConversationContext';

// const handleAddConversation = (conversation: Conversation) => {
//     dispatch({
//       type: 'startConversation',
//       payload: conversation
//     })
// }

// const handleConversationChange = (conversation: Conversation) => {
//   dispatch({
//     type: 'changeConversation',
//     payload: conversation
//   })
// }

// const handleConversationDelete = (conversation: Conversation) => {
//   dispatch({
//     type: 'deleteConversation',
//     payload: conversation
//   })
// }

// const handleSendMessage = (message: Message) => {
//   dispatch({
//     type: 'updateConversation',
//     payload: message
//   })
// }



function App() {
  return (
    <div className="h-screen flex bg-primary">
      <ConversationProvider>
        <div className="basis-1/6">
          <Navbar/>
        </div>
        <div className="basis-5/6">
          <Chat/>
        </div>
      </ConversationProvider>
    </div>
  );
}

export default App;
