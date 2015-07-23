bl_info = {
    'name': 'Export as Jet OBJ',
    'location': 'File > Export',
    'category': 'Import-Export',
}

import bpy
import os
import shutil

class ExportAsJetObj(bpy.types.Operator):
    bl_idname = 'file.jetobj'
    bl_label = 'Export as Jet OBJ'
    bl_options = {'REGISTER'}

    def execute(self, context):
        folder = 'D:\\code\\lua-quadrant\\'
        base = os.path.splitext(os.path.basename(bpy.data.filepath))[0]
        objpath = bpy.data.filepath.replace('.blend','.obj')
        mtlpath = bpy.data.filepath.replace('.blend','.mtl')
        bpy.ops.export_scene.obj(
            filepath=objpath, 
            check_existing=True, 
            axis_forward='Y', 
            axis_up='Z', 
            use_selection=False, 
            use_animation=False, 
            use_mesh_modifiers=True, 
            use_edges=True, 
            use_smooth_groups=False, 
            #use_smooth_groups_bitflags=False, 
            use_normals=True, 
            use_uvs=True, 
            use_materials=True, 
            use_triangles=True, 
            use_nurbs=False, 
            use_vertex_groups=False, 
            use_blen_objects=True, 
            group_by_object=False, 
            group_by_material=False, 
            keep_vertex_order=False, 
            global_scale=1, 
            path_mode='AUTO')

        dst = os.path.join(folder,'mesh',base+'.obj')
        if os.path.exists(dst):
            os.remove(dst) 
        shutil.copy(objpath,dst)

        dst = os.path.join(folder,'material',base+'.mtl')
        if os.path.exists(dst):
            os.remove(dst) 
        shutil.copy(mtlpath,dst)
        return {'FINISHED'}

def menu_func(self, context):
    self.layout.operator(ExportAsJetObj.bl_idname)

addon_keymaps = []

def register():
    bpy.utils.register_class(ExportAsJetObj)
    bpy.types.INFO_MT_file_export.append(menu_func)

    # handle the keymap
    wm = bpy.context.window_manager
    km = wm.keyconfigs.addon.keymaps.new(name='Object Mode', space_type='EMPTY')

    kmi = km.keymap_items.new(ExportAsJetObj.bl_idname, 'SPACE', 'PRESS', ctrl=True, shift=True)
    #kmi = km.keymap_items.new(ExportAsJetObj.bl_idname, 'S' 'PRESS', ctrl=True) #ctrl=True, shift=True)

    addon_keymaps.append((km, kmi))


def unregister():
    bpy.utils.unregister_class(ExportAsJetObj)
    bpy.types.INFO_MT_file_export.remove(menu_func)

    wm = bpy.context.window_manager
    for km in addon_keymaps:
        wm.keyconfigs.addon.keymaps.remove(km)
    addon_keymaps.clear()

if __name__ == '__main__':
    register()
