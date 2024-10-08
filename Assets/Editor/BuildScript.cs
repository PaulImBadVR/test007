using UnityEditor;
using UnityEngine;

public class BuildScript
{
    public static void BuildAndroid()
    {
        Debug.Log("BuildScript.BuildAndroid is called");
        string[] scenes = { "Assets/Scenes/SampleScene.unity" };
        BuildPipeline.BuildPlayer(scenes, "Builds/windowbuild.exe", BuildTarget.StandaloneWindows, BuildOptions.None);
        Debug.Log("BuildScript.BuildAndroid is exiting. 1");
    }
}
