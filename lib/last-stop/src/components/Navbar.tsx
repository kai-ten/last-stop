import React from 'react';
import logo from '../assets/logo.png';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faRotateLeft } from '@fortawesome/free-solid-svg-icons';
import { faGithub } from '@fortawesome/free-brands-svg-icons';
import ConversationList from './ConversationList';
// import { useConversationDispatch } from '../contexts/ConversationContext';
// import { newConversation } from '../services/ConversationAPI';
import { useNewConversationMutation } from '../services/ConversationAPI';

function Navbar() {

  // const conversationDispatch = useConversationDispatch();
  const [newConversation, conversation] = useNewConversationMutation();

  const startNewConversation = async () => {
    // conversationDispatch({
    //   type: 'newConversation',
    //   payload: { id: '', userId: '', messages: []}
    // })
    // await newConversation({});
    window.location.reload();
  }

  return (
    <div className="h-screen border-r bg-white">
      <div className="px-20 py-10 flex flex-col">
        <div className='justify-center items-center object-fill bg-opacity-0 mb-2'>
          <img src={logo} alt='logo'/>
        </div>
      </div>
      <div className="px-4 py-6 flex flex-col ">
        <nav aria-label="Main Nav" className="">
          <a
            onClick={startNewConversation}
            href="#" 
            className="flex items-center gap-2 rounded-lg px-4 py-2 text-gray-500 hover:bg-gray-100 hover:text-gray-700"
          >
            <FontAwesomeIcon icon={faRotateLeft} />
            <span className="text-md font-medium"> New conversation </span>
          </a>

          <a
            href="https://github.com/circulatedev/last-stop" 
            target="_blank"
            className="flex items-center gap-2 rounded-lg px-4 py-2 text-gray-500 hover:bg-gray-100 hover:text-gray-700"
          >
            <FontAwesomeIcon icon={faGithub} />
            <span className="text-md font-medium"> Last Stop </span>
          </a>
          <ConversationList/>
        </nav>
      </div>
    </div>
  );
}

export default Navbar;
