-- Drop the problematic trigger and function
DROP TRIGGER IF EXISTS update_last_activity_on_chat ON public.chat_messages;

-- Recreate function to get user_id from conversation
CREATE OR REPLACE FUNCTION update_user_last_activity_on_chat()
RETURNS TRIGGER AS $$
DECLARE
    v_user_id UUID;
BEGIN
    -- Get user_id from the conversation
    SELECT user_id INTO v_user_id
    FROM public.chat_conversations
    WHERE id = NEW.conversation_id;
    
    -- Update user's last activity date
    IF v_user_id IS NOT NULL THEN
        UPDATE public.user_profiles
        SET last_activity_date = CURRENT_DATE
        WHERE id = v_user_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recreate trigger with the new function
CREATE TRIGGER update_last_activity_on_chat
    AFTER INSERT ON public.chat_messages
    FOR EACH ROW
    EXECUTE FUNCTION update_user_last_activity_on_chat();
