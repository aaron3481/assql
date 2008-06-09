package com.maclema.mysql
{
	import com.maclema.logging.Logger;
	import com.maclema.mysql.events.MySqlErrorEvent;
	import com.maclema.mysql.events.MySqlEvent;
	
	import flash.events.EventDispatcher;
	
	import mx.rpc.IResponder;
	
	/**
	 * Dispatched when an SQL error occurs
	 **/
	[Event(name="sqlError", type="com.maclema.mysql.events.MySqlErrorEvent")]
	
	/**
	 * Dispatched when an query successfull executes
	 **/
    [Event(name="response", type="com.maclema.mysql.events.MySqlEvent")]
    
    /**
    * Dispatche when a data manipulation query successfully executes
    **/
    [Event(name="result", type="com.maclema.mysql.events.MySqlEvent")]
    
    /**
    * This class provieds a place to set additional token-level data for MySql queries. It also allows an IResponder to be attached
    * for an individual call.
    **/
	public dynamic class MySqlToken extends EventDispatcher
	{
		private var _responders:Array = new Array();
		
		/**
		 * The result returned by the query. Either a ResultSet (for query statements), or an object with
		 * two properties, affectedRows and insertID for a response event.
		 **/
		public var result:Object;
		
		/**
		 * Constructs a new MySqlToken
		 **/
		public function MySqlToken()
		{
			this.addEventListener(MySqlEvent.RESPONSE, handleResponse);
            this.addEventListener(MySqlEvent.RESULT, handleResponse);
            this.addEventListener(MySqlErrorEvent.SQL_ERROR, handleError);
		}
		
		/**
		 * An array of IResponder handlers that will be called when the MySql query completes.
		 **/
		public function get responders():Array {
			return _responders;
		}
		
		private function handleResponse(e:MySqlEvent):void {
        	if ( this.hasResponder() ) {
	        	var data:Object;
	        	if ( e.type == MySqlEvent.RESULT ) {
	        		data = e.resultSet;
	        	}
	        	else {
	        		data = {
	        			affectedRows: e.affectedRows,
	        			insertID: e.insertID
	        		}
	        	}
	        	
	        	Logger.info(this, "Dispatching Result/Response Responders");
	        	
	        	for ( var i:int=0; i<responders.length; i++ ) {
	        		var responder:IResponder = IResponder(responders[i]);
	        		responder.result(data);
	        	}
        	}
        }
        
        private function handleError(e:MySqlErrorEvent):void {
        	if ( this.hasResponder() ) {
	        	var data:Object = e.text;
	        	
	        	Logger.info(this, "Dispatching Fault Responders");
	        	
	        	for ( var i:int=0; i<responders.length; i++ ) {
	        		var responder:IResponder = IResponder(responders[i]);
	        		responder.fault(data);
	        	}
        	}
        }
		
		/**
		 * Adds a responder to an array of responders
		 **/
		public function addResponder(responder:IResponder):void {
			responders.push(responder);
		}
		
		/**
		 * Determines if this token has at least one IResponder registered
		 **/
		public function hasResponder():Boolean {
			if ( responders.length > 0 ) {
				return true;
			}
			return false;
		}
	}
}