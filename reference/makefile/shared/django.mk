


# Django manage.py command helper
ifeq ($(IN_DOCKER),true)
	undefine EXEC_CMD
	MANAGE_CMD = python manage.py
else
	IN_DOCKER=false
	MANAGE_CMD = $(EXEC_CMD) python manage.py
endif
