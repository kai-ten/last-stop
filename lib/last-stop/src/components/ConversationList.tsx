import { useEffect } from "react";
// import { useConversationDispatch, useConversationState } from "../contexts/ConversationContext";
// import { getAllConversations } from "../services/ConversationAPI";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faComments } from '@fortawesome/free-solid-svg-icons';

function ConversationList() {

    useEffect(() => {
        // getAllConversations()
        //     .then(convs => {
        //         conversationDispatch({
        //             type: "getAllConversations",
        //             payload: convs
        //         });
        //     })
    })

  
    return (
      <details className="group [&_summary::-webkit-details-marker]:hidden">
        <summary
          className="flex cursor-pointer items-center justify-between rounded-lg px-4 py-2 text-gray-500 hover:bg-gray-100 hover:text-gray-700"
        >
          <div className="flex items-center gap-2">
            <FontAwesomeIcon icon={faComments} />
            <span className="text-md font-medium"> Conversations </span>
          </div>

          <span className="shrink-0 transition duration-300 group-open:-rotate-180">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              className="h-5 w-5"
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path
                fillRule="evenodd"
                d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
                clipRule="evenodd"
              />
            </svg>
          </span>
        </summary>

        <nav aria-label="Conversations Nav" className="mt-2 flex flex-col px-4">
            {/* { state.allConversations?.map((conv) => (
                 <a
                 key={conv.id}
                 href="#"
                 className="flex items-center gap-2 rounded-lg px-4 py-2 text-gray-500 hover:bg-gray-100 hover:text-gray-700">
                    <span className="text-md font-medium"> {conv.id} </span>
                 </a>
            ))} */}
          <a
            href="#"
            className="flex items-center gap-2 rounded-lg px-4 py-2 text-gray-500 hover:bg-gray-100 hover:text-gray-700"
          >
            <span className="text-md font-medium"> Coming soon </span>
          </a>

        </nav>
      </details>
    );
  }
  
  export default ConversationList;