<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

use App\User;

use Illuminate\Support\Facades\Auth;
use Validator;

class UserController extends Controller
{
    public $sucessStatus = 200;


    public function login(Request $request)
    { 
        $loginData = $request->validate([
            'email' => 'email|required',
            'password' => 'required'
        ]);

        if (!auth()->attempt($loginData)) {
            return response(['message' => 'Invalid Credentials']);
        }

        $accessToken = auth()->user()->createToken('MyApp')->accessToken;

        return response(['user' => auth()->user(), 'access_token' => $accessToken]);
    }

    public function register(Request $request)
    {
    	$validator = Validator::make($request->all(), [
    		'name'=>'required',
    		'email'=>'required|email',
    		'password'=>'required',
    		'c_password'=>'required|same:password',
    	]);

        // dd($request->all());

    	if ($validator->fails()) {
    		return reponse()->json(['error'=>$validator->errors()], 401);
    	}

    	$input = $request->all();

    	$input['password'] = bcrypt($input['password']);

        
        $user = User::create($input); 

        $success['token'] =  $user->createToken('MyApp')->accessToken;
    	$sucess['name'] = $user->name;

    	return response()->json(['success'=>$success], $this->sucessStatus);
    }

    public function details()
    {
    	$user = Auth::user();
    	return response()->json(['success'=>$user], $this->sucessStatus);
    }
}
