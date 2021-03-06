
event_table = {
    See         = "e_exit",
    Train       = "e_train",
    Let         = "e_let",
    Forget      = "e_forget",
    Mode        = "e_mode",
    I           = "e_i_will",
}

interact_fsm = rfsm.state{

    ----------------------------------
    -- state SUB_MENU               --
    ----------------------------------
    SUB_MENU = rfsm.state{
        entry=function()
            print("in substate MENU : waiting for speech command!")
        end,

        doo = function()
            while true do
                -- speak(ispeak_port, "What should I do?")
                result = SM_Reco_Grammar(speechRecog_port, grammar)
                print("received REPLY: ", result:toString() )
                local cmd = result:get(1):asString()
                rfsm.send_events(fsm, event_table[cmd])
                rfsm.yield(true)
            end
        end
    },

    ----------------------------------
    -- states                       --
    ----------------------------------

    SUB_EXIT = rfsm.state{
        entry=function()
            speak(ispeak_port, "Ok, bye bye")
            rfsm.send_events(fsm, 'e_menu_done')
        end
    },

    SUB_TRAIN = rfsm.state{
        entry=function()
            local obj = result:get(3):asString()
            local b = onTheFlyRec_train(onTheFlyRec_port, obj)
        end
    },

    SUB_MODE = rfsm.state{
        entry=function()
            local user = result:get(3):asString()
            local b = onTheFlyRec_mode(onTheFlyRec_port, user)
        end
    },

    SUB_LET = rfsm.state{
        entry=function()
            local b = onTheFlyRec_recognize(onTheFlyRec_port)
        end
    },

    SUB_FORGET = rfsm.state{
        entry=function()
            --local obj = result:get(3):asString()
            --local b = onTheFlyRec_forget(onTheFlyRec_port, obj)
            --not sure how onTheFlyRec deals with individual objects. All will get deleted
            local b = onTheFlyRec_forget(onTheFlyRec_port)
        end
    },

    SUB_TEACH_OBJ = rfsm.state{
        entry=function()
            print("in SUB_TEACH_OBJ")
            local str = SM_RGM_Expand_Auto(speechRecog_port, "#Object")
            print("done with name ", str)
            local b = onTheFlyRec_train(onTheFlyRec_port, str)
       end
   },

    ----------------------------------
    -- state transitions            --
    ----------------------------------

    rfsm.trans{ src='initial', tgt='SUB_MENU'},
    rfsm.transition { src='SUB_MENU', tgt='SUB_EXIT', events={ 'e_exit' } },

    rfsm.transition { src='SUB_MENU', tgt='SUB_TRAIN', events={ 'e_train' } },
    rfsm.transition { src='SUB_TRAIN', tgt='SUB_MENU', events={ 'e_done' } },

    rfsm.transition { src='SUB_MENU', tgt='SUB_LET', events={ 'e_let' } },
    rfsm.transition { src='SUB_LET', tgt='SUB_MENU', events={ 'e_done' } },

    rfsm.transition { src='SUB_MENU', tgt='SUB_MODE', events={ 'e_mode' } },
    rfsm.transition { src='SUB_MODE', tgt='SUB_MENU', events={ 'e_done' } },

    rfsm.transition { src='SUB_MENU', tgt='SUB_FORGET', events={ 'e_forget' } },
    rfsm.transition { src='SUB_FORGET', tgt='SUB_MENU', events={ 'e_done' } },

    rfsm.transition { src='SUB_MENU', tgt='SUB_TEACH_OBJ', events={ 'e_i_will' } },
    rfsm.transition { src='SUB_TEACH_OBJ', tgt='SUB_MENU', events={ 'e_done' } },

}
