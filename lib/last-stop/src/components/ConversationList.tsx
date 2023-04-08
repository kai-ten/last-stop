import { useEffect } from "react";
import { useConversationDispatch, useConversationState } from "../contexts/ConversationContext";
// import { getAllConversations } from "../services/ConversationAPI";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faComments } from '@fortawesome/free-solid-svg-icons';

function ConversationList() {
    const conversationDispatch = useConversationDispatch();
    const state = useConversationState();

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
            { state.allConversations?.map((conv) => (
                 <a
                 key={conv.id}
                 href="#"
                 className="flex items-center gap-2 rounded-lg px-4 py-2 text-gray-500 hover:bg-gray-100 hover:text-gray-700">
                    <span className="text-md font-medium"> {conv.id} </span>
                 </a>
            ))}
          <a
            href="#"
            className="flex items-center gap-2 rounded-lg px-4 py-2 text-gray-500 hover:bg-gray-100 hover:text-gray-700"
          >
            {/* <svg
              xmlns="http://www.w3.org/2000/svg"
              className="h-5 w-5 opacity-75"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              strokeWidth="2"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636"
              />
            </svg> */}

            <span className="text-md font-medium"> Banned Users </span>
          </a>

          <a
            href="#"
            className="flex items-center gap-2 rounded-lg px-4 py-2 text-gray-500 hover:bg-gray-100 hover:text-gray-700"
          >
            {/* <svg
              xmlns="http://www.w3.org/2000/svg"
              className="h-5 w-5 opacity-75"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              strokeWidth="2"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
              />
            </svg> */}

            <span className="text-md font-medium"> Calendar </span>
          </a>
        </nav>
      </details>
    );
  }
  
  export default ConversationList;