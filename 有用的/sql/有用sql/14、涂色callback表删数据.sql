SELECT count(*), msg_type FROM t_crm_tuse_callback_msg group by msg_type ;

DELETE FROM t_crm_tuse_callback_msg WHERE msg_type IN (703066,
703105,
800003,
905050,
905052,
905051,
905250,
905251,
902200004,
902500001,
902500002,
902500003,
902500005)